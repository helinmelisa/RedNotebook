import SwiftUI

/// Cream paper with a faint Hobonichi-style grid.
struct GridPaper: View {
    var spacing: CGFloat = Theme.gridSpacing

    var body: some View {
        Canvas { context, size in
            var lines = Path()
            var x: CGFloat = spacing
            while x < size.width {
                lines.move(to: CGPoint(x: x, y: 0))
                lines.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            var y: CGFloat = spacing
            while y < size.height {
                lines.move(to: CGPoint(x: 0, y: y))
                lines.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            context.stroke(lines, with: .color(Theme.grid), lineWidth: 0.5)

            // Faint fibres so the paper doesn't look like a flat screen colour
            var rng = SeededRandom(seed: 11)
            for _ in 0..<Int(size.width * size.height / 140) {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let r = Double.random(in: 0.4...1.0, using: &rng)
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                             with: .color(Color(red: 0.55, green: 0.45, blue: 0.30).opacity(0.07)))
            }
        }
        .background(Theme.paper)
        .allowsHitTesting(false)
    }
}

#Preview {
    GridPaper().ignoresSafeArea()
}

/// Bullet journal dot grid: a dot where the grid lines would cross.
struct DotPaper: View {
    var spacing: CGFloat = Theme.gridSpacing

    var body: some View {
        Canvas { context, size in
            let dot = GraphicsContext.Shading.color(Theme.ink.opacity(0.22))
            var dots = Path()
            for y in stride(from: spacing, to: size.height, by: spacing) {
                for x in stride(from: spacing, to: size.width, by: spacing) {
                    dots.addEllipse(in: CGRect(x: x - 0.9, y: y - 0.9, width: 1.8, height: 1.8))
                }
            }
            context.fill(dots, with: dot)
        }
        .background(Theme.paper)
        .allowsHitTesting(false)
    }
}

/// Red satin ribbon bookmark hanging from the top of the page.
struct Ribbon: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [Theme.ribbon.opacity(0.85), Theme.ribbon, Theme.ribbon.opacity(0.8)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: 9, height: 70)
            // Forked tail
            Path { p in
                p.move(to: .zero)
                p.addLine(to: CGPoint(x: 9, y: 0))
                p.addLine(to: CGPoint(x: 9, y: 8))
                p.addLine(to: CGPoint(x: 4.5, y: 4))
                p.addLine(to: CGPoint(x: 0, y: 8))
                p.closeSubpath()
            }
            .fill(Theme.ribbon)
            .frame(width: 9, height: 8)
        }
        .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
        .allowsHitTesting(false)
    }
}

extension View {
    /// Lays scrolling content on a notebook page: margins either side, and the paper and ribbon underneath
    /// scrolling along with it, so the whole page moves together and the writing stays on its squares.
    func notebookPage(dotted: Bool = false) -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 28)
            .padding(.trailing, 44) // keep text clear of the ribbon
            .background(alignment: .top) {
                Group {
                    if dotted { DotPaper() } else { GridPaper() }
                }
                // Paper well past both ends, for pulling the page past the top or bottom
                // (a whole number of squares, so the grid still starts on the page's top edge)
                .padding(.vertical, -Theme.gridSpacing * 100)
            }
            .overlay(alignment: .topTrailing) {
                Ribbon().padding(.trailing, 22)
            }
    }
}
