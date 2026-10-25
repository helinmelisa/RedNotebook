import AVFoundation

/// Quiet paper sounds, made in code: a page turning, a sticker peeling off its sheet and pressing down.
/// They follow the ring/silent switch and can be turned off in the cover settings.
@MainActor
final class SoundEffects {
    static let shared = SoundEffects()
    static let enabledKey = "soundsOn"

    enum Sound: CaseIterable {
        case pageTurn, peel, stick, tick
    }

    private let engine = AVAudioEngine()
    private var players: [Sound: AVAudioPlayerNode] = [:]
    private var buffers: [Sound: AVAudioPCMBuffer] = [:]
    private var isReady = false

    private init() {}

    func play(_ sound: Sound) {
        guard UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true else { return }
        prepareIfNeeded()
        guard isReady, let player = players[sound], let buffer = buffers[sound] else { return }
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        if !player.isPlaying { player.play() }
    }

    private func prepareIfNeeded() {
        guard !isReady else { return }
        // .ambient respects the silent switch and mixes with music instead of stopping it
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { return }
        for sound in Sound.allCases {
            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            players[sound] = player
            buffers[sound] = Self.render(sound, format: format)
        }
        engine.mainMixerNode.outputVolume = 0.6
        do {
            try engine.start()
            isReady = true
        } catch {
            isReady = false
        }
    }

    /// Synthesises each sound into a short buffer.
    private static func render(_ sound: Sound, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let rate = format.sampleRate
        let duration: Double = switch sound {
        case .pageTurn: 0.38
        case .peel: 0.16
        case .stick: 0.08
        case .tick: 0.05
        }
        let frames = AVAudioFrameCount(duration * rate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
              let samples = buffer.floatChannelData?[0] else { return nil }
        buffer.frameLength = frames

        var rng = SeededRandom(seed: 99)
        var low: Float = 0 // one-pole low-pass state, to soften the noise
        for i in 0..<Int(frames) {
            let t = Double(i) / rate
            let progress = t / duration
            let noise = Float.random(in: -1...1, using: &rng)
            var value: Float
            switch sound {
            case .pageTurn:
                // A swish: soft noise that swells and fades, brightening as the page lifts
                let cutoff = Float(0.08 + 0.25 * sin(progress * .pi))
                low += cutoff * (noise - low)
                value = low * Float(sin(progress * .pi)) * 0.9
            case .peel:
                // Brighter, scratchier noise that rises
                low += 0.45 * (noise - low)
                value = (noise - low) * Float(progress) * Float(1 - progress) * 2.4
            case .stick:
                // A soft low thump
                value = Float(sin(2 * .pi * 140 * t) * exp(-t * 60)) * 0.8
            case .tick:
                // A pen tap
                value = Float(sin(2 * .pi * 1800 * t) * exp(-t * 140)) * 0.35
            }
            samples[i] = value
        }
        return buffer
    }
}
