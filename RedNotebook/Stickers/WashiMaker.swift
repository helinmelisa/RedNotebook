import SwiftUI

enum WashiPattern: String, CaseIterable, Identifiable {
    case stripes, grid, dots, gingham, hearts, stars, flowers, waves, plain

    var id: Self { self }
}

/// A roll of washi tape: its pattern and colour. Saved on the sticker as "pattern:colour".
struct WashiStyle: Hashable {
    var pattern: WashiPattern
    var colorIndex: Int

    static let colors: [(name: String, color: Color)] = [
        ("Sakura", Color(red: 0.96, green: 0.70, blue: 0.75)),
        ("Mint", Color(red: 0.62, green: 0.85, blue: 0.76)),
        ("Butter", Color(red: 0.98, green: 0.85, blue: 0.55)),
        ("Sky", Color(red: 0.65, green: 0.80, blue: 0.94)),
        ("Lavender", Color(red: 0.78, green: 0.72, blue: 0.92)),
        ("Peach", Color(red: 0.98, green: 0.75, blue: 0.60)),
        ("Matcha", Color(red: 0.70, green: 0.80, blue: 0.55)),
        ("Hot pink", Color(red: 1.0, green: 0.45, blue: 0.68)),
        ("Tomato", Color(red: 0.92, green: 0.42, blue: 0.38)),
        ("Kraft", Color(red: 0.80, green: 0.68, blue: 0.52)),
        ("Cream", Color(red: 0.96, green: 0.92, blue: 0.82)),
        ("Ink", Color(red: 0.25, green: 0.27, blue: 0.35)),
    ]

    var color: Color { Self.colors[colorIndex % Self.colors.count].color }
    /// Dark tape gets light writing.
    var isDark: Bool { colorIndex % Self.colors.count == 11 }

    var value: String { "\(pattern.rawValue):\(colorIndex)" }

    init(pattern: WashiPattern, colorIndex: Int) {
        self.pattern = pattern
        self.colorIndex = colorIndex
    }

    init?(value: String) {
        let parts = value.split(separator: ":")
        guard parts.count == 2, let pattern = WashiPattern(rawValue: String(parts[0])), let index = Int(parts[1]) else { return nil }
        self.init(pattern: pattern, colorIndex: index)
    }
}

/// The tape itself, any size: colour, pattern and torn ends, a little see-through.
struct WashiPaper: View {
    let color: Color
    let pattern: WashiPattern

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.clip(to: ZigzagEnds().path(in: rect))
            context.fill(Path(rect), with: .color(color))

            let ink = GraphicsContext.Shading.color(.white.opacity(0.55))
            switch pattern {
            case .stripes:
                var x: CGFloat = -size.height
                while x < size.width {
                    var stripe = Path()
                    stripe.move(to: CGPoint(x: x, y: size.height))
                    stripe.addLine(to: CGPoint(x: x + size.height, y: 0))
                    context.stroke(stripe, with: ink, lineWidth: 4)
                    x += 12
                }
            case .grid:
                var lines = Path()
                for x in stride(from: 6.0, to: size.width, by: 8) {
                    lines.move(to: CGPoint(x: x, y: 0)); lines.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 5.0, to: size.height, by: 8) {
                    lines.move(to: CGPoint(x: 0, y: y)); lines.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(lines, with: ink, lineWidth: 1)
            case .dots:
                for x in stride(from: 8.0, to: size.width, by: 12) {
                    for y in stride(from: 7.0, to: size.height, by: 12) {
                        context.fill(Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4)), with: ink)
                    }
                }
            case .gingham:
                let band = GraphicsContext.Shading.color(.white.opacity(0.32))
                for x in stride(from: 0.0, to: size.width, by: 12) {
                    context.fill(Path(CGRect(x: x, y: 0, width: 6, height: size.height)), with: band)
                }
                for y in stride(from: 0.0, to: size.height, by: 12) {
                    context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 6)), with: band)
                }
            case .hearts, .stars, .flowers:
                let symbol = switch pattern {
                case .hearts: "heart.fill"
                case .stars: "star.fill"
                default: "camera.macro"
                }
                var shape = context.resolve(Image(systemName: symbol))
                shape.shading = ink
                var row = 0
                for y in stride(from: 8.0, to: size.height, by: 13) {
                    for x in stride(from: row.isMultiple(of: 2) ? 8.0 : 15.0, to: size.width, by: 14) {
                        context.draw(shape, in: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
                    }
                    row += 1
                }
            case .waves:
                for y in stride(from: 6.0, to: size.height, by: 8) {
                    var wave = Path()
                    wave.move(to: CGPoint(x: 0, y: y))
                    for x in stride(from: 0.0, to: size.width, by: 10) {
                        wave.addQuadCurve(to: CGPoint(x: x + 10, y: y), control: CGPoint(x: x + 5, y: y + (Int(x / 10).isMultiple(of: 2) ? -4 : 4)))
                    }
                    context.stroke(wave, with: ink, lineWidth: 1.4)
                }
            case .plain:
                // Washi fibres
                var rng = SeededRandom(seed: 7)
                for _ in 0..<Int(size.width / 3) {
                    let x = Double.random(in: 0...size.width, using: &rng), y = Double.random(in: 0...size.height, using: &rng)
                    var fibre = Path()
                    fibre.move(to: CGPoint(x: x, y: y))
                    fibre.addLine(to: CGPoint(x: x + Double.random(in: 3...8, using: &rng), y: y + Double.random(in: -1...1, using: &rng)))
                    context.stroke(fibre, with: .color(.white.opacity(0.25)), lineWidth: 0.6)
                }
            }
        }
        .opacity(0.85) // tape is a little see-through
        .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
    }
}

/// Your own tape: as long as what's written on it.
struct CustomWashi: View {
    let style: WashiStyle
    let text: String

    var body: some View {
        Text(text.isEmpty ? " " : text)
            .font(Theme.handwriting(size: 20).weight(.semibold))
            .foregroundStyle(style.isDark ? .white.opacity(0.92) : Theme.ink.opacity(0.85))
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 20)
            .frame(minWidth: 120)
            .frame(height: 32)
            .background(WashiPaper(color: style.color, pattern: style.pattern))
    }
}

/// "Make your own tape": pick a pattern and a colour, write on it, and stick it on the page.
struct WashiMaker: View {
    var onMake: (WashiStyle, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("lastWashi") private var lastWashi = "stripes:0"
    @State private var style = WashiStyle(pattern: .stripes, colorIndex: 0)
    @State private var text = ""
    @FocusState private var writing: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    CustomWashi(style: style, text: text.isEmpty ? "write on me" : text)
                        .opacity(text.isEmpty ? 0.75 : 1)
                        .rotationEffect(.degrees(-3))
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .animation(.snappy, value: style)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(title: "Write on it", color: style.color)
                        TextField("Weekend! · Porto · ♡ …", text: $text)
                            .font(Theme.handwriting(size: 24))
                            .focused($writing)
                            .submitLabel(.done)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Theme.ink.opacity(0.05)))
                            .onChange(of: text) { _, new in
                                if new.count > 24 { text = String(new.prefix(24)) }
                            }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(title: "Pattern", color: style.color)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 10)], spacing: 12) {
                            ForEach(WashiPattern.allCases) { pattern in
                                Button { style.pattern = pattern } label: {
                                    WashiPaper(color: style.color, pattern: pattern)
                                        .frame(width: 88, height: 26)
                                        .padding(5)
                                        .overlay(RoundedRectangle(cornerRadius: 6)
                                            .stroke(pattern == style.pattern ? Theme.ink : .clear, lineWidth: 1.5))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(pattern.rawValue.capitalized)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(title: "Colour", color: style.color)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 10)], spacing: 10) {
                            ForEach(WashiStyle.colors.indices, id: \.self) { index in
                                Button { style.colorIndex = index } label: {
                                    Circle()
                                        .fill(WashiStyle.colors[index].color)
                                        .frame(width: 34, height: 34)
                                        .overlay(Circle().stroke(Theme.paper, lineWidth: 2).padding(2))
                                        .overlay(Circle().stroke(index == style.colorIndex ? Theme.ink : .clear, lineWidth: 2))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(WashiStyle.colors[index].name)
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(GridPaper().ignoresSafeArea())
            .navigationTitle("Make washi tape")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.font(Theme.serif(16))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Stick it") {
                        lastWashi = style.value
                        onMake(style, text.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .font(Theme.serif(16, .semibold))
                }
            }
        }
        .onAppear {
            style = WashiStyle(value: lastWashi) ?? style
            writing = true
        }
    }
}
