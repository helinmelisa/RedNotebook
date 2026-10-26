import SwiftUI

/// The time of year, for the seasonal touches on the desk around the closed notebook.
enum Season: String {
    case spring, summer, autumn, winter

    /// From today's month (northern hemisphere). Launch with `--season winter` (etc.) to preview another.
    static var current: Season {
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "--season"), index + 1 < arguments.count,
           let season = Season(rawValue: arguments[index + 1]) {
            return season
        }
        switch Calendar.current.component(.month, from: .now) {
        case 3...5: return .spring
        case 6...8: return .summer
        case 9...11: return .autumn
        default: return .winter
        }
    }
}

/// The season drifting across the desk: falling leaves, snow, sakura petals or summer light.
/// Everything moves slowly and loops; with Reduce Motion on it stays still.
struct SeasonalDesk: View {
    var season: Season = .current

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                draw(in: &context, size: size, time: time)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// One drifting thing, all of it decided once from a seed so it loops smoothly.
    private struct Particle {
        let x: Double, y: Double, size: Double
        /// Points per second downwards (negative drifts up).
        let fall: Double
        let sway: Double, swaySpeed: Double, spin: Double, phase: Double, tone: Int

        /// Where it is at `time`, wrapping round the screen.
        func position(at time: Double, in size: CGSize) -> CGPoint {
            let margin = 40.0
            let height = size.height + 2 * margin
            var y = (self.y * height + fall * time).truncatingRemainder(dividingBy: height)
            if y < 0 { y += height }
            let x = self.x * size.width + sway * sin(time * swaySpeed + phase)
            return CGPoint(x: x, y: y - margin)
        }
    }

    private func particles(_ count: Int, seed: UInt64, size: ClosedRange<Double>, fall: ClosedRange<Double>,
                           sway: ClosedRange<Double>, spin: ClosedRange<Double>) -> [Particle] {
        var rng = SeededRandom(seed: seed)
        func random(_ range: ClosedRange<Double>) -> Double { Double.random(in: range, using: &rng) }
        return (0..<count).map { i in
            Particle(x: random(0...1), y: random(0...1), size: random(size), fall: random(fall),
                     sway: random(sway), swaySpeed: random(0.3...0.9), spin: random(spin) * (i.isMultiple(of: 2) ? 1 : -1),
                     phase: random(0...(2 * .pi)), tone: i)
        }
    }

    private func draw(in context: inout GraphicsContext, size: CGSize, time: Double) {
        switch season {
        case .autumn:
            let colors = [Color(red: 0.88, green: 0.45, blue: 0.15), Color(red: 0.74, green: 0.24, blue: 0.16),
                          Color(red: 0.86, green: 0.63, blue: 0.22), Color(red: 0.58, green: 0.38, blue: 0.22)]
            for leaf in particles(20, seed: 31, size: 14...28, fall: 14...30, sway: 18...40, spin: 0.4...1.2) {
                var symbol = context.resolve(Image(systemName: "leaf.fill"))
                symbol.shading = .color(colors[leaf.tone % colors.count].opacity(0.85))
                var layer = context
                let point = leaf.position(at: time, in: size)
                layer.translateBy(x: point.x, y: point.y)
                layer.rotate(by: .radians(leaf.phase + time * leaf.spin))
                // Tumbling: the leaf turns over as it falls, so it narrows and widens
                layer.scaleBy(x: 0.35 + 0.65 * abs(cos(time * leaf.spin * 0.8 + leaf.phase)), y: 1)
                layer.addFilter(.shadow(color: .black.opacity(0.18), radius: 1.5, x: 1, y: 1.5))
                layer.draw(symbol, in: CGRect(x: -leaf.size / 2, y: -leaf.size / 2, width: leaf.size, height: leaf.size))
            }
        case .winter:
            // A colder light on the desk, and snow falling
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.86, green: 0.91, blue: 0.97).opacity(0.3)))
            for flake in particles(70, seed: 47, size: 4...14, fall: 18...48, sway: 6...16, spin: 0.1...0.6) {
                var symbol = context.resolve(Image(systemName: "snowflake"))
                // Smaller flakes are further away: fainter and slower
                symbol.shading = .color(.white.opacity(0.45 + flake.size / 30))
                var layer = context
                let point = flake.position(at: time * (0.5 + flake.size / 20), in: size)
                layer.translateBy(x: point.x, y: point.y)
                layer.rotate(by: .radians(time * flake.spin + flake.phase))
                layer.draw(symbol, in: CGRect(x: -flake.size / 2, y: -flake.size / 2, width: flake.size, height: flake.size))
            }
        case .spring:
            for petal in particles(40, seed: 53, size: 6...11, fall: 10...24, sway: 30...60, spin: 0.6...1.6) {
                var layer = context
                let point = petal.position(at: time, in: size)
                // Blown sideways a little as well as falling
                layer.translateBy(x: point.x + (time * 6).truncatingRemainder(dividingBy: size.width), y: point.y)
                layer.rotate(by: .radians(petal.phase + time * petal.spin))
                layer.scaleBy(x: 1, y: 0.4 + 0.6 * abs(sin(time * petal.spin + petal.phase)))
                let w = petal.size
                let shape = Path(ellipseIn: CGRect(x: -w / 2, y: -w * 0.35, width: w, height: w * 0.7))
                layer.fill(shape, with: .color(Color(red: 1.0, green: 0.74 + Double(petal.tone % 5) * 0.02, blue: 0.84).opacity(0.9)))
            }
        case .summer:
            // Sunlight through leaves: soft bright patches that sway and breathe
            var light = context
            light.addFilter(.blur(radius: 18))
            for patch in particles(14, seed: 61, size: 30...80, fall: 0...0, sway: 10...24, spin: 0.2...0.5) {
                let r = patch.size
                let x = patch.x * size.width + patch.sway * sin(time * patch.swaySpeed * 0.5 + patch.phase)
                let y = patch.y * size.height + patch.sway * 0.6 * cos(time * patch.swaySpeed * 0.4 + patch.phase)
                let glow = 0.3 + 0.2 * sin(time * patch.spin + patch.phase)
                light.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r * 0.7, width: 2 * r, height: r * 1.4)),
                           with: .color(Color(red: 1.0, green: 0.96, blue: 0.82).opacity(glow)))
            }
            // Dust motes floating up in the light
            for mote in particles(24, seed: 67, size: 1.5...3, fall: -12 ... -4, sway: 8...20, spin: 0.5...1) {
                let point = mote.position(at: time, in: size)
                let twinkle = 0.4 + 0.4 * sin(time * mote.spin * 3 + mote.phase)
                context.fill(Path(ellipseIn: CGRect(x: point.x, y: point.y, width: mote.size, height: mote.size)),
                             with: .color(.white.opacity(twinkle)))
            }
        }
    }
}
