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
        engine.mainMixerNode.outputVolume = 0.5
        do {
            try engine.start()
            isReady = true
        } catch {
            isReady = false
        }
    }

    /// Synthesises each sound into a short buffer.
    ///
    /// Paper doesn't hiss evenly: it's a soft, low swish carrying lots of tiny crackles as the fibres bend.
    /// So the paper sounds are built from those two layers.
    private static func render(_ sound: Sound, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let rate = format.sampleRate
        let duration: Double = switch sound {
        case .pageTurn: 0.45
        case .peel: 0.22
        case .stick: 0.07
        case .tick: 0.04
        }
        let frames = Int(duration * rate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames)),
              let samples = buffer.floatChannelData?[0] else { return nil }
        buffer.frameLength = AVAudioFrameCount(frames)

        var rng = SeededRandom(seed: sound == .peel ? 7 : 99)
        switch sound {
        case .pageTurn:
            // Envelope: quick lift, longer settle
            func envelope(_ p: Double) -> Double { p < 0.25 ? p / 0.25 : pow(1 - (p - 0.25) / 0.75, 1.6) }
            addSwish(samples, frames: frames, rate: rate, level: 0.10, smoothing: 0.035, envelope: envelope, rng: &rng)
            addCrackles(samples, frames: frames, rate: rate, perSecond: 220, level: 0.16, envelope: envelope, rng: &rng)
        case .peel:
            // Adhesive letting go: crackles getting denser, then a sudden stop
            func envelope(_ p: Double) -> Double { p < 0.85 ? pow(p / 0.85, 1.5) : (1 - p) / 0.15 }
            addSwish(samples, frames: frames, rate: rate, level: 0.04, smoothing: 0.08, envelope: envelope, rng: &rng)
            addCrackles(samples, frames: frames, rate: rate, perSecond: 380, level: 0.10, envelope: envelope, rng: &rng)
        case .stick:
            // A soft fingertip press: a muffled low thump
            for i in 0..<frames {
                let t = Double(i) / rate
                samples[i] = Float(sin(2 * .pi * 110 * t) * exp(-t * 70)) * 0.22
            }
        case .tick:
            // A pen tip touching paper
            for i in 0..<frames {
                let t = Double(i) / rate
                samples[i] = Float(sin(2 * .pi * 2400 * t) * exp(-t * 220)) * 0.08
            }
        }
        return buffer
    }

    /// Low, soft noise: the air moving as the paper moves.
    private static func addSwish(_ samples: UnsafeMutablePointer<Float>, frames: Int, rate: Double, level: Float,
                                 smoothing: Float, envelope: (Double) -> Double, rng: inout SeededRandom) {
        var low: Float = 0
        for i in 0..<frames {
            low += smoothing * (Float.random(in: -1...1, using: &rng) - low)
            samples[i] += low * 6 * level * Float(envelope(Double(i) / Double(frames)))
        }
    }

    /// Many tiny, bright clicks of different strengths, scattered in time.
    private static func addCrackles(_ samples: UnsafeMutablePointer<Float>, frames: Int, rate: Double, perSecond: Double,
                                    level: Float, envelope: (Double) -> Double, rng: inout SeededRandom) {
        let chance = perSecond / rate
        var i = 0
        while i < frames {
            let shape = envelope(Double(i) / Double(frames))
            if Double.random(in: 0...1, using: &rng) < chance * shape {
                let length = Int(Double.random(in: 0.0006...0.003, using: &rng) * rate)
                let strength = level * Float.random(in: 0.2...1, using: &rng)
                var previous: Float = 0
                for j in 0..<length where i + j < frames {
                    let noise = Float.random(in: -1...1, using: &rng)
                    let bright = noise - previous // crude high-pass: keeps the crackle crisp, not boomy
                    previous = noise
                    samples[i + j] += bright * strength * Float(exp(-Double(j) / Double(max(length, 1)) * 4))
                }
            }
            i += 1
        }
    }
}
