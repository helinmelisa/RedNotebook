import SwiftUI

/// The moods you can pick for a day, and the colour each one paints the calendar.
enum Moods {
    static let all = ["🥰", "😊", "🙂", "😐", "😔", "😢", "😡", "😴"]

    static func name(_ mood: String) -> String {
        switch mood {
        case "🥰": "In love"
        case "😊": "Happy"
        case "🙂": "Good"
        case "😐": "Okay"
        case "😔": "Down"
        case "😢": "Sad"
        case "😡": "Angry"
        case "😴": "Tired"
        default: mood
        }
    }

    static func color(_ mood: String) -> Color {
        switch mood {
        case "🥰": Color(red: 0.97, green: 0.62, blue: 0.72)
        case "😊": Color(red: 1.00, green: 0.80, blue: 0.35)
        case "🙂": Color(red: 0.62, green: 0.82, blue: 0.55)
        case "😐": Color(red: 0.78, green: 0.76, blue: 0.70)
        case "😔": Color(red: 0.60, green: 0.68, blue: 0.80)
        case "😢": Color(red: 0.45, green: 0.62, blue: 0.92)
        case "😡": Color(red: 0.92, green: 0.40, blue: 0.35)
        case "😴": Color(red: 0.72, green: 0.65, blue: 0.90)
        default: Theme.hairline
        }
    }
}

/// A hand-drawn mood face in ink and flat colour, used instead of emoji so moods look drawn in the notebook.
struct MoodFace: View {
    let mood: String

    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            let line = max(s * 0.07, 0.8)
            let ink = GraphicsContext.Shading.color(Theme.ink)
            func p(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func dot(_ x: Double, _ y: Double, _ r: Double = 0.055) {
                context.fill(Path(ellipseIn: CGRect(x: (x - r) * s, y: (y - r) * s, width: 2 * r * s, height: 2 * r * s)), with: ink)
            }
            func curve(_ from: (Double, Double), _ to: (Double, Double), _ control: (Double, Double), shading: GraphicsContext.Shading = ink) {
                var path = Path()
                path.move(to: p(from.0, from.1))
                path.addQuadCurve(to: p(to.0, to.1), control: p(control.0, control.1))
                context.stroke(path, with: shading, style: StrokeStyle(lineWidth: line, lineCap: .round))
            }
            func blush() {
                for x in [0.22, 0.78] {
                    context.fill(Path(ellipseIn: CGRect(x: (x - 0.08) * s, y: 0.56 * s, width: 0.16 * s, height: 0.09 * s)),
                                 with: .color(Color(red: 1.0, green: 0.55, blue: 0.60).opacity(0.55)))
                }
            }

            // Face: flat colour with an ink outline
            let face = Path(ellipseIn: CGRect(x: line / 2, y: line / 2, width: s - line, height: s - line))
            context.fill(face, with: .color(Moods.color(mood).mix(with: Theme.paper, by: 0.2)))
            context.stroke(face, with: ink, lineWidth: line * 0.8)

            switch mood {
            case "🥰":
                for x in [0.35, 0.65] {
                    var heart = Path()
                    let c = p(x, 0.42), r = 0.07 * s
                    heart.move(to: CGPoint(x: c.x, y: c.y + r * 1.1))
                    heart.addCurve(to: CGPoint(x: c.x, y: c.y - r * 0.4), control1: CGPoint(x: c.x - r * 1.6, y: c.y), control2: CGPoint(x: c.x - r * 0.7, y: c.y - r * 1.5))
                    heart.addCurve(to: CGPoint(x: c.x, y: c.y + r * 1.1), control1: CGPoint(x: c.x + r * 0.7, y: c.y - r * 1.5), control2: CGPoint(x: c.x + r * 1.6, y: c.y))
                    context.fill(heart, with: .color(Theme.red))
                }
                curve((0.35, 0.63), (0.65, 0.63), (0.5, 0.78))
                blush()
            case "😊":
                curve((0.27, 0.44), (0.42, 0.44), (0.345, 0.34))
                curve((0.58, 0.44), (0.73, 0.44), (0.655, 0.34))
                curve((0.32, 0.6), (0.68, 0.6), (0.5, 0.8))
                blush()
            case "🙂":
                dot(0.36, 0.42); dot(0.64, 0.42)
                curve((0.37, 0.63), (0.63, 0.63), (0.5, 0.72))
            case "😐":
                dot(0.36, 0.42); dot(0.64, 0.42)
                curve((0.37, 0.65), (0.63, 0.65), (0.5, 0.65))
            case "😔":
                curve((0.27, 0.42), (0.42, 0.46), (0.35, 0.47))
                curve((0.58, 0.46), (0.73, 0.42), (0.65, 0.47))
                curve((0.4, 0.69), (0.6, 0.69), (0.5, 0.64))
            case "😢":
                dot(0.36, 0.42); dot(0.64, 0.42)
                curve((0.37, 0.7), (0.63, 0.7), (0.5, 0.6))
                context.fill(Path(ellipseIn: CGRect(x: 0.28 * s, y: 0.5 * s, width: 0.09 * s, height: 0.13 * s)),
                             with: .color(Color(red: 0.35, green: 0.55, blue: 0.95)))
            case "😡":
                curve((0.24, 0.3), (0.43, 0.38), (0.33, 0.33))
                curve((0.57, 0.38), (0.76, 0.3), (0.67, 0.33))
                dot(0.36, 0.46); dot(0.64, 0.46)
                curve((0.37, 0.71), (0.63, 0.71), (0.5, 0.61))
            case "😴":
                curve((0.27, 0.42), (0.42, 0.42), (0.345, 0.5))
                curve((0.58, 0.42), (0.73, 0.42), (0.655, 0.5))
                context.stroke(Path(ellipseIn: CGRect(x: 0.45 * s, y: 0.6 * s, width: 0.1 * s, height: 0.12 * s)), with: ink, lineWidth: line * 0.8)
                context.draw(Text("z").font(.system(size: s * 0.28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.45, green: 0.40, blue: 0.75)), at: p(0.86, 0.14))
            default:
                dot(0.36, 0.42); dot(0.64, 0.42)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(Moods.name(mood))
    }
}
