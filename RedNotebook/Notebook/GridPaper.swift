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
