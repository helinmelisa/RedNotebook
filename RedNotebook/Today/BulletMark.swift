import SwiftUI

/// The bullet journal symbol at the start of a line. A finished task gets a hand-inked ✕
/// that draws itself, one stroke after the other.
struct BulletMark: View {
    let item: BulletItem

    var body: some View {
        let isDone = item.kind == .task && item.state == .done

        // The invisible bullet keeps the text baseline, so the row lines up whichever mark is shown
        Text(isDone ? "•" : item.symbol)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Theme.ink)
            .opacity(isDone ? 0 : 1)
            .frame(width: 18)
            .overlay {
                if isDone {
                    InkCross()
                        .frame(width: 12, height: 12)
                        .offset(y: 1)
                }
            }
    }
}

/// Two slightly curved strokes, drawn like a quick pen mark.
struct InkCross: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        let style = StrokeStyle(lineWidth: 2.4, lineCap: .round)
        ZStack {
            Stroke(from: CGPoint(x: 0.1, y: 0.12), to: CGPoint(x: 0.92, y: 0.9), bend: 0.08)
                .trim(from: 0, to: min(progress * 2, 1))
                .stroke(Theme.accent, style: style)
            Stroke(from: CGPoint(x: 0.88, y: 0.08), to: CGPoint(x: 0.12, y: 0.92), bend: -0.06)
                .trim(from: 0, to: max(progress * 2 - 1, 0))
                .stroke(Theme.accent, style: style)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.32)) { progress = 1 }
        }
        .accessibilityHidden(true)
    }

    private struct Stroke: Shape {
        let from: CGPoint
        let to: CGPoint
        let bend: CGFloat

        func path(in rect: CGRect) -> Path {
            func point(_ p: CGPoint) -> CGPoint { CGPoint(x: rect.minX + p.x * rect.width, y: rect.minY + p.y * rect.height) }
            let control = CGPoint(x: (from.x + to.x) / 2 + bend, y: (from.y + to.y) / 2 - bend)
            var path = Path()
            path.move(to: point(from))
            path.addQuadCurve(to: point(to), control: point(control))
            return path
        }
    }
}
