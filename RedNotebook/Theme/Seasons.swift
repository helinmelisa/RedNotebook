import SwiftUI

/// The time of year, for small seasonal touches on the desk and the cover.
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

/// Things lying on the desk around the notebook: fallen leaves, snow, petals or summer light.
struct SeasonalDesk: View {
    var season: Season = .current

    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: 31)
            func random(_ range: ClosedRange<Double>) -> Double { Double.random(in: range, using: &rng) }

            switch season {
            case .autumn:
                let colors = [Color(red: 0.88, green: 0.45, blue: 0.15), Color(red: 0.74, green: 0.24, blue: 0.16),
                              Color(red: 0.86, green: 0.63, blue: 0.22), Color(red: 0.58, green: 0.38, blue: 0.22)]
                for i in 0..<22 {
                    var leaf = context.resolve(Image(systemName: "leaf.fill"))
                    leaf.shading = .color(colors[i % colors.count].opacity(0.85))
                    var layer = context
                    layer.translateBy(x: random(0...size.width), y: random(0...size.height))
                    layer.rotate(by: .degrees(random(0...360)))
                    let side = random(14...30)
                    layer.addFilter(.shadow(color: .black.opacity(0.18), radius: 1.5, x: 1, y: 1.5))
                    layer.draw(leaf, in: CGRect(x: -side / 2, y: -side / 2, width: side, height: side))
                }
            case .winter:
                // A colder light on the desk, and snow
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.86, green: 0.91, blue: 0.97).opacity(0.3)))
                for _ in 0..<70 {
                    var flake = context.resolve(Image(systemName: "snowflake"))
                    flake.shading = .color(.white.opacity(random(0.6...0.95)))
                    let side = random(5...15)
                    var layer = context
                    layer.translateBy(x: random(0...size.width), y: random(0...size.height))
                    layer.rotate(by: .degrees(random(0...60)))
                    layer.draw(flake, in: CGRect(x: -side / 2, y: -side / 2, width: side, height: side))
                }
            case .spring:
                for _ in 0..<45 {
                    var layer = context
                    layer.translateBy(x: random(0...size.width), y: random(0...size.height))
                    layer.rotate(by: .degrees(random(0...360)))
                    let w = random(6...11)
                    let petal = Path(ellipseIn: CGRect(x: -w / 2, y: -w * 0.35, width: w, height: w * 0.7))
                    layer.fill(petal, with: .color(Color(red: 1.0, green: random(0.74...0.84), blue: random(0.80...0.88)).opacity(0.9)))
                }
            case .summer:
                // Sunlight through leaves: soft bright patches
                var light = context
                light.addFilter(.blur(radius: 18))
                for _ in 0..<14 {
                    let r = random(30...80)
                    light.fill(Path(ellipseIn: CGRect(x: random(0...size.width) - r, y: random(0...size.height) - r, width: 2 * r, height: r * 1.4)),
                               with: .color(Color(red: 1.0, green: 0.96, blue: 0.82).opacity(0.45)))
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A little something tucked under the cover's elastic band.
struct SeasonalCharm: View {
    var season: Season = .current
    let scale: CGFloat

    var body: some View {
        Group {
            switch season {
            case .autumn:
                Image(systemName: "leaf.fill")
                    .font(.system(size: 46 * scale))
                    .foregroundStyle(LinearGradient(colors: [Color(red: 0.92, green: 0.55, blue: 0.18), Color(red: 0.72, green: 0.22, blue: 0.14)],
                                                    startPoint: .top, endPoint: .bottom))
                    .rotationEffect(.degrees(35))
            case .winter:
                Image(systemName: "snowflake")
                    .font(.system(size: 50 * scale, weight: .regular))
                    .foregroundStyle(.white.opacity(0.95))
                    .rotationEffect(.degrees(12))
            case .spring:
                DrawnStickerView(sticker: .sakura).scaleEffect(0.8 * scale).rotationEffect(.degrees(-60))
            case .summer:
                DrawnStickerView(sticker: .lemon).scaleEffect(0.75 * scale).rotationEffect(.degrees(18))
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 2 * scale, x: scale, y: 2 * scale)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
