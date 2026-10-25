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
        }
        .background(Theme.paper)
        .allowsHitTesting(false)
    }
}

#Preview {
    GridPaper().ignoresSafeArea()
}
