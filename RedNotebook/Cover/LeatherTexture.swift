import SwiftUI

/// Fine speckle + grain lines drawn over the red cover to suggest leather.
struct LeatherTexture: View {
    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: 42)

            // Pores: tiny light and dark specks
            for _ in 0..<Int(size.width * size.height / 18) {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let r = CGFloat.random(in: 0.3...1.1, using: &rng)
                let light = Bool.random(using: &rng)
                let color: Color = light ? .white.opacity(0.06) : .black.opacity(0.10)
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)), with: .color(color))
            }

            // Wrinkles: short faint curved strokes
            for _ in 0..<140 {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let length = CGFloat.random(in: 6...22, using: &rng)
                let bend = CGFloat.random(in: -4...4, using: &rng)
                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addQuadCurve(to: CGPoint(x: x + length, y: y + bend / 2),
                                  control: CGPoint(x: x + length / 2, y: y + bend))
                context.stroke(path, with: .color(.black.opacity(0.07)), lineWidth: 0.6)
            }
        }
        .allowsHitTesting(false)
    }
}
