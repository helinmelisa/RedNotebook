import SwiftUI

/// The paper a sticky note is made of.
enum NoteDesign: String, CaseIterable, Identifiable {
    case classic, lined, grid, torn, taped, pinned, index, heart, cloud, speech, tag

    var id: Self { self }

    var name: String {
        switch self {
        case .classic: "Post-it"
        case .lined: "Lined"
        case .grid: "Grid"
        case .torn: "Torn out"
        case .taped: "Taped"
        case .pinned: "Pinned"
        case .index: "Index card"
        case .heart: "Heart"
        case .cloud: "Cloud"
        case .speech: "Speech"
        case .tag: "Tag"
        }
    }

    /// Shaped notes are a fixed size with the writing in the middle; the rest grow with what's written.
    var isShaped: Bool { [.heart, .cloud].contains(self) }

    var size: CGSize {
        switch self {
        case .heart: CGSize(width: 156, height: 142)
        case .cloud: CGSize(width: 176, height: 120)
        case .index: CGSize(width: 180, height: 112)
        case .tag: CGSize(width: 170, height: 96)
        default: CGSize(width: 150, height: 130)
        }
    }

    var insets: EdgeInsets {
        switch self {
        case .heart: EdgeInsets(top: 26, leading: 28, bottom: 42, trailing: 28)
        case .cloud: EdgeInsets(top: 30, leading: 26, bottom: 20, trailing: 26)
        case .torn: EdgeInsets(top: 24, leading: 12, bottom: 12, trailing: 12)
        case .taped, .pinned: EdgeInsets(top: 22, leading: 12, bottom: 12, trailing: 12)
        case .index: EdgeInsets(top: 16, leading: 12, bottom: 10, trailing: 12)
        case .speech: EdgeInsets(top: 12, leading: 14, bottom: 28, trailing: 14)
        case .tag: EdgeInsets(top: 12, leading: 36, bottom: 12, trailing: 14)
        default: EdgeInsets(top: 12, leading: 12, bottom: 14, trailing: 12)
        }
    }
}

/// A sticky note's design and colour. Saved on the sticker as "design:colour".
struct NoteStyle: Hashable {
    var design: NoteDesign
    var colorIndex: Int

    static let colors: [(name: String, color: Color)] = [
        ("Butter", Color(red: 1.0, green: 0.91, blue: 0.52)),
        ("Blush", Color(red: 0.99, green: 0.78, blue: 0.80)),
        ("Mint", Color(red: 0.72, green: 0.92, blue: 0.80)),
        ("Sky", Color(red: 0.73, green: 0.86, blue: 0.98)),
        ("Lilac", Color(red: 0.84, green: 0.78, blue: 0.97)),
        ("Peach", Color(red: 1.0, green: 0.80, blue: 0.64)),
        ("Lime", Color(red: 0.86, green: 0.95, blue: 0.55)),
        ("Coral", Color(red: 1.0, green: 0.62, blue: 0.56)),
        ("Hot pink", Color(red: 1.0, green: 0.55, blue: 0.75)),
        ("Aqua", Color(red: 0.55, green: 0.90, blue: 0.90)),
        ("Paper", Color(red: 0.995, green: 0.99, blue: 0.97)),
        ("Kraft", Color(red: 0.84, green: 0.72, blue: 0.56)),
    ]

    var color: Color { Self.colors[colorIndex % Self.colors.count].color }

    var value: String { "\(design.rawValue):\(colorIndex)" }

    init(design: NoteDesign, colorIndex: Int) {
        self.design = design
        self.colorIndex = colorIndex
    }

    init?(value: String) {
        let parts = value.split(separator: ":")
        guard parts.count == 2, let design = NoteDesign(rawValue: String(parts[0])),
              let index = Int(parts[1]) else { return nil }
        self.init(design: design, colorIndex: index)
    }
}

/// A sticky note with something written on it, to stick anywhere on a page.
struct NoteSticker: View {
    let style: NoteStyle
    let text: String
    /// Grey hint text instead, for the maker's preview.
    var placeholder: String? = nil

    var body: some View {
        let design = style.design
        let writing = Text(text.isEmpty ? (placeholder ?? " ") : text)
            .font(Theme.handwriting(size: 20))
            .lineSpacing(1)
            .foregroundStyle(Theme.ink.opacity(text.isEmpty ? 0.35 : 0.9))
            .multilineTextAlignment(design.isShaped ? .center : .leading)
            .lineLimit(design.isShaped ? 4 : 12)
            .minimumScaleFactor(design.isShaped ? 0.6 : 1)
            .padding(design.insets)
        Group {
            if design.isShaped {
                writing.frame(width: design.size.width, height: design.size.height)
            } else {
                writing
                    .frame(width: design.size.width, alignment: .topLeading)
                    .frame(minHeight: design.size.height, alignment: .topLeading)
            }
        }
            .background { NotePaper(style: style) }
            .overlay(alignment: .top) { NoteTopping(style: style) }
    }
}

/// The note's paper: shape, colour and printed lines.
private struct NotePaper: View {
    let style: NoteStyle

    var body: some View {
        let color = style.color
        Group {
            switch style.design {
            case .classic:
                Rectangle().fill(color)
                    // The bottom edge lifts a little, like a real Post-it
                    .overlay(alignment: .bottom) {
                        LinearGradient(colors: [.clear, .black.opacity(0.07)], startPoint: .top, endPoint: .bottom)
                            .frame(height: 18)
                    }
            case .lined:
                Rectangle().fill(color).overlay { RuledLines(spacing: 23, top: 34, margin: true) }
            case .grid:
                Rectangle().fill(color).overlay { GridPaper(spacing: 10).opacity(0.7).blendMode(.multiply) }
            case .torn:
                TornTop().fill(color).overlay { RuledLines(spacing: 23, top: 46, margin: false).clipShape(TornTop()) }
            case .taped, .pinned:
                Rectangle().fill(color)
            case .index:
                Rectangle().fill(color).overlay { RuledLines(spacing: 20, top: 34, margin: false, indexCard: true) }
            case .heart:
                NoteHeart().fill(color)
            case .cloud:
                NoteCloud().fill(color)
            case .speech:
                SpeechBubble().fill(color)
            case .tag:
                NoteTagShape().fill(color)
            }
        }
        .shadow(color: .black.opacity(0.18), radius: 2, x: 1, y: 2)
    }
}

/// What holds the note on: tape, a pin, the spiral's holes, a tag's string.
private struct NoteTopping: View {
    let style: NoteStyle

    var body: some View {
        switch style.design {
        case .taped:
            WashiPaper(color: WashiStyle.colors[(style.colorIndex + 3) % WashiStyle.colors.count].color, pattern: .stripes)
                .frame(width: 70, height: 20)
                .rotationEffect(.degrees(-4))
                .offset(y: -8)
        case .pinned:
            ZStack {
                Circle().fill(Color(red: 0.86, green: 0.18, blue: 0.20))
                Circle().fill(.white.opacity(0.6)).frame(width: 4, height: 4).offset(x: -2.5, y: -2.5)
            }
            .frame(width: 14, height: 14)
            .shadow(color: .black.opacity(0.35), radius: 1.5, x: 2, y: 3)
            .offset(y: 4)
        case .torn:
            HStack(spacing: 11) {
                ForEach(0..<8, id: \.self) { _ in
                    Circle().fill(Theme.paper).frame(width: 6, height: 6)
                        .overlay(Circle().stroke(.black.opacity(0.12), lineWidth: 0.5))
                }
            }
            .offset(y: 10)
        case .tag:
            HStack {
                Circle().fill(Theme.paper).frame(width: 10, height: 10)
                    .overlay(Circle().stroke(.black.opacity(0.2), lineWidth: 1))
                    .overlay(Circle().stroke(Color(red: 0.75, green: 0.6, blue: 0.4), lineWidth: 1.2).padding(-3))
                Spacer()
            }
            .padding(.leading, 14)
            .frame(maxHeight: .infinity)
        default:
            EmptyView()
        }
    }
}

/// Printed lines on memo paper or an index card.
private struct RuledLines: View {
    let spacing: CGFloat
    let top: CGFloat
    let margin: Bool
    var indexCard = false

    var body: some View {
        Canvas { context, size in
            var lines = Path()
            for y in stride(from: top, to: size.height - 4, by: spacing) {
                lines.move(to: CGPoint(x: 0, y: y))
                lines.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(lines, with: .color(Color(red: 0.35, green: 0.5, blue: 0.75).opacity(0.3)), lineWidth: 0.7)
            if indexCard {
                var header = Path()
                header.move(to: CGPoint(x: 0, y: top - 12))
                header.addLine(to: CGPoint(x: size.width, y: top - 12))
                context.stroke(header, with: .color(Color(red: 0.85, green: 0.25, blue: 0.3).opacity(0.6)), lineWidth: 1)
            }
            if margin {
                var line = Path()
                line.move(to: CGPoint(x: 8, y: 0))
                line.addLine(to: CGPoint(x: 8, y: size.height))
                context.stroke(line, with: .color(Color(red: 0.85, green: 0.25, blue: 0.3).opacity(0.45)), lineWidth: 0.8)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Shapes

/// Paper torn out of a spiral notebook: a ragged top edge.
private struct TornTop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var rng = SeededRandom(seed: 3)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 4))
        var x = rect.minX
        while x < rect.maxX {
            x = min(x + Double.random(in: 3...7, using: &rng), rect.maxX)
            path.addLine(to: CGPoint(x: x, y: rect.minY + Double.random(in: 0...6, using: &rng)))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct NoteHeart: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.3),
                      control1: CGPoint(x: rect.minX + w * 0.3, y: rect.minY + h * 0.78),
                      control2: CGPoint(x: rect.minX, y: rect.minY + h * 0.55))
        path.addArc(center: CGPoint(x: rect.minX + w * 0.25, y: rect.minY + h * 0.3), radius: w * 0.25,
                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: CGPoint(x: rect.minX + w * 0.75, y: rect.minY + h * 0.3), radius: w * 0.25,
                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX, y: rect.minY + h * 0.55),
                      control2: CGPoint(x: rect.maxX - w * 0.3, y: rect.minY + h * 0.78))
        path.closeSubpath()
        return path
    }
}

/// Puffs of cloud: overlapping circles over a rounded base.
private struct NoteCloud: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path(roundedRect: CGRect(x: rect.minX + w * 0.06, y: rect.minY + h * 0.4, width: w * 0.88, height: h * 0.6),
                        cornerRadius: h * 0.3)
        for (cx, cy, r) in [(0.24, 0.48, 0.2), (0.45, 0.32, 0.27), (0.70, 0.4, 0.22), (0.86, 0.6, 0.14)] {
            let radius = r * w
            path.addEllipse(in: CGRect(x: rect.minX + cx * w - radius, y: rect.minY + cy * h - radius * 0.85,
                                       width: radius * 2, height: radius * 1.7))
        }
        return path
    }
}

/// A rounded bubble with a little tail at the bottom left.
private struct SpeechBubble: Shape {
    func path(in rect: CGRect) -> Path {
        let body = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - 14)
        var path = Path(roundedRect: body, cornerRadius: 16)
        path.move(to: CGPoint(x: body.minX + 26, y: body.maxY - 1))
        path.addLine(to: CGPoint(x: body.minX + 18, y: rect.maxY))
        path.addLine(to: CGPoint(x: body.minX + 44, y: body.maxY - 1))
        path.closeSubpath()
        return path
    }
}

/// A luggage tag: the left end cut to a point.
private struct NoteTagShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cut: CGFloat = 22
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 4), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 4))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - 4, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + 10))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY - 10))
        path.closeSubpath()
        return path
    }
}

// MARK: - Maker

/// "Write a sticky note": pick its paper and colour, write on it, then stick it on the page and move it
/// wherever you like. Also used to rewrite a note that's already stuck on.
struct NoteMaker: View {
    var initialStyle: NoteStyle? = nil
    var initialText = ""
    var onMake: (NoteStyle, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("lastNote") private var lastNote = "classic:0"
    @State private var style = NoteStyle(design: .classic, colorIndex: 0)
    @State private var text = ""
    @FocusState private var writing: Bool

    private var isEditing: Bool { initialStyle != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    NoteSticker(style: style, text: text, placeholder: "Write me…")
                        .rotationEffect(.degrees(-2))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 170)
                        .animation(.snappy, value: style)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(title: "Write on it", color: style.color)
                        TextField("Call mum · buy film · ♡ …", text: $text, axis: .vertical)
                            .lineLimit(2...6)
                            .font(Theme.handwriting(size: 22))
                            .focused($writing)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Theme.ink.opacity(0.05)))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(title: "Design", color: style.color)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: 10)], spacing: 12) {
                            ForEach(NoteDesign.allCases) { design in
                                Button { style.design = design } label: {
                                    VStack(spacing: 4) {
                                        NoteSticker(style: NoteStyle(design: design, colorIndex: style.colorIndex), text: "")
                                            .scaleEffect(0.42)
                                            .frame(width: 80, height: 66)
                                        Text(design.name)
                                            .font(Theme.serif(11))
                                            .foregroundStyle(Theme.inkSecondary)
                                    }
                                    .padding(4)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(design == style.design ? Theme.ink : .clear, lineWidth: 1.5))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(design.name)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(title: "Colour", color: style.color)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 10)], spacing: 10) {
                            ForEach(NoteStyle.colors.indices, id: \.self) { index in
                                Button { style.colorIndex = index } label: {
                                    Circle()
                                        .fill(NoteStyle.colors[index].color)
                                        .frame(width: 34, height: 34)
                                        .overlay(Circle().stroke(Theme.ink.opacity(0.12), lineWidth: 1))
                                        .overlay(Circle().stroke(index == style.colorIndex ? Theme.ink : .clear, lineWidth: 2).padding(-3))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(NoteStyle.colors[index].name)
                            }
                        }
                    }
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(GridPaper().ignoresSafeArea())
            .navigationTitle(isEditing ? "Sticky note" : "Write a sticky note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.font(Theme.serif(16))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Done" : "Stick it") {
                        lastNote = style.value
                        onMake(style, text.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .font(Theme.serif(16, .semibold))
                }
            }
        }
        .onAppear {
            style = initialStyle ?? NoteStyle(value: lastNote) ?? style
            text = initialText
            writing = true
        }
    }
}
