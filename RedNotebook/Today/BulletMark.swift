import SwiftUI

/// The mark at the start of a line. Tasks get a hand-drawn checkbox: tap it and an inked ✓ draws itself.
/// Events keep their ○ and notes their –, bullet journal style.
struct BulletMark: View {
    let item: BulletItem

    var body: some View {
        if item.kind == .task {
            // The invisible bullet keeps the text baseline, so the box lines up with the words
            Text("•")
                .font(.system(size: 18, weight: .bold))
                .opacity(0)
                .frame(width: 20)
                .overlay {
                    ZStack {
                        HandDrawnBox()
                            .stroke(Theme.ink.opacity(item.state == .open ? 0.75 : 0.4), lineWidth: 1.4)
                            .frame(width: 15, height: 15)
                        switch item.state {
                        case .done:
                            InkCheck().frame(width: 17, height: 17).offset(x: 2, y: -2)
                        case .migrated:
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Theme.inkTertiary)
                        case .cancelled:
                            Rectangle().fill(Theme.inkTertiary).frame(width: 13, height: 1.4).rotationEffect(.degrees(-35))
                        case .open:
                            EmptyView()
                        }
                    }
                    .offset(y: 1)
                }
        } else {
            Text(item.symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.ink)
                .frame(width: 20)
        }
    }
}

/// A square drawn by hand: the sides bow very slightly and the corner doesn't quite close.
struct HandDrawnBox: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + w * 0.04, y: rect.minY + h * 0.06))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.02, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.minY - h * 0.04))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - h * 0.03), control: CGPoint(x: rect.maxX + w * 0.04, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.minX + w * 0.02, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.maxY + h * 0.03))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.14), control: CGPoint(x: rect.minX - w * 0.03, y: rect.midY))
        return path
    }
}

/// A quick pen tick that draws itself, overshooting the box a little like a real one.
struct InkCheck: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        Tick()
            .trim(from: 0, to: progress)
            .stroke(Theme.accent, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
            .onAppear {
                withAnimation(.easeOut(duration: 0.28)) { progress = 1 }
            }
            .accessibilityHidden(true)
    }

    private struct Tick: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.55))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.minY + rect.height * 0.85))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                              control: CGPoint(x: rect.minX + rect.width * 0.62, y: rect.minY + rect.height * 0.35))
            return path
        }
    }
}
