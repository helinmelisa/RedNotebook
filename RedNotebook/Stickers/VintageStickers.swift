import SwiftUI

/// Vintage ephemera: wax seals, old stamps, paper scraps, pressed flowers and typed words, in warm muted colours.
struct VintageStickerView: View {
    let sticker: DrawnSticker
    var text: String = ""

    var body: some View {
        switch sticker {
        case .waxSealRose: WaxSeal(color: Vintage.wax) { RoseEmboss() }.frame(width: 58, height: 58)
        case .waxSealSprig: WaxSeal(color: Vintage.gold) { SprigEmboss() }.frame(width: 58, height: 58)
        case .envelopeHeart: EnvelopeHeart(note: text).frame(width: 78, height: 52).stickerOutline()
        case .stampLavender:
            VintageStamp(label: "Lavender", value: "29") { LavenderSprig(color: Vintage.lavender) }
        case .stampFern:
            VintageStamp(label: "POSTA", value: "10") { Fern() }
        case .newspaperScrap: NewspaperScrap(headline: text.isEmpty ? "the days are golden" : text).stickerOutline(1.5)
        case .musicSheet: MusicSheet().stickerOutline(1.5)
        case .kraftPaper: KraftPaper().writing(text, size: 17, lines: 3).stickerOutline(1.5)
        case .butterflyNight: Butterfly(wing: Color(red: 0.12, green: 0.11, blue: 0.12), pattern: Vintage.gold).frame(width: 66, height: 50).stickerOutline()
        case .butterflyCream: Butterfly(wing: Color(red: 0.95, green: 0.91, blue: 0.84), pattern: Vintage.dustyRose).frame(width: 66, height: 50).stickerOutline()
        case .driedLavender: DriedBunch().frame(width: 40, height: 76).stickerOutline()
        case .daisy: Daisy().frame(width: 48, height: 74).stickerOutline()
        case .typewriter: Typewriter().frame(width: 74, height: 52).stickerOutline()
        case .satinBow: SatinBow().frame(width: 66, height: 50).stickerOutline()
        case .plasterTape: PlasterTape().rotationEffect(.degrees(-25))
        case .quoteStrip: TypedStrip(text: text.isEmpty ? "there is more to love" : text)
        case .pressedFlower: PressedFlower().stickerOutline(1.5)
        case .typedWords:
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array((text.isEmpty ? "write the stars" : text).split(separator: " ").prefix(4).enumerated()), id: \.offset) { i, word in
                    TypedStrip(text: String(word)).offset(x: CGFloat(i % 2) * 8)
                }
            }
        default: EmptyView()
        }
    }
}

enum Vintage {
    static let cream = Color(red: 0.96, green: 0.93, blue: 0.86)
    static let kraft = Color(red: 0.74, green: 0.58, blue: 0.42)
    static let sepia = Color(red: 0.45, green: 0.35, blue: 0.26)
    static let inkBrown = Color(red: 0.30, green: 0.24, blue: 0.20)
    static let dustyRose = Color(red: 0.85, green: 0.62, blue: 0.60)
    static let sage = Color(red: 0.55, green: 0.62, blue: 0.48)
    static let lavender = Color(red: 0.62, green: 0.52, blue: 0.75)
    static let wax = Color(red: 0.70, green: 0.52, blue: 0.40)
    static let gold = Color(red: 0.78, green: 0.62, blue: 0.38)

    /// A typewriter face, for typed labels.
    static func typed(_ size: CGFloat) -> Font { .custom("AmericanTypewriter", size: size) }
}

// MARK: - Wax seals & envelope

/// A blob of wax, slightly irregular at the edge, with a design pressed into it.
private struct WaxSeal<Emboss: View>: View {
    let color: Color
    @ViewBuilder var emboss: Emboss

    var body: some View {
        ZStack {
            WaxBlob().fill(RadialGradient(colors: [color.mix(with: .white, by: 0.2), color, color.mix(with: .black, by: 0.3)],
                                          center: .init(x: 0.38, y: 0.32), startRadius: 2, endRadius: 34))
            Circle().stroke(color.mix(with: .black, by: 0.25), lineWidth: 1.5).padding(9)
            Circle().stroke(.white.opacity(0.25), lineWidth: 1).padding(10).offset(x: -0.6, y: -0.6)
            emboss
                .foregroundStyle(color.mix(with: .black, by: 0.3))
                .shadow(color: .white.opacity(0.35), radius: 0, x: -0.7, y: -0.7)
                .frame(width: 30, height: 30)
        }
        .shadow(color: .black.opacity(0.2), radius: 1.5, x: 0.5, y: 1.5)
    }
}

private struct WaxBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var rng = SeededRandom(seed: 17)
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let steps = 18
        for i in 0...steps {
            let angle = Double(i) / Double(steps) * 2 * .pi
            let r = rect.width / 2 * CGFloat.random(in: 0.88...1.0, using: &rng)
            let point = CGPoint(x: c.x + cos(angle) * r, y: c.y + sin(angle) * r)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

private struct RoseEmboss: View {
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle().trim(from: 0.1, to: 0.85).stroke(lineWidth: 1.6)
                    .frame(width: 8 + CGFloat(i) * 7).rotationEffect(.degrees(Double(i) * 70))
            }
        }
    }
}

private struct SprigEmboss: View {
    var body: some View {
        ZStack {
            Capsule().frame(width: 1.6, height: 26).rotationEffect(.degrees(20))
            ForEach(0..<4) { i in
                Ellipse().frame(width: 6, height: 10)
                    .rotationEffect(.degrees(i.isMultiple(of: 2) ? -40 : 40))
                    .offset(x: i.isMultiple(of: 2) ? -4 : 4, y: CGFloat(i) * 5 - 8)
            }
        }
    }
}

private struct EnvelopeHeart: View {
    let note: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3).fill(Vintage.cream)
            Path { p in
                p.move(to: .zero); p.addLine(to: CGPoint(x: 39, y: 28)); p.addLine(to: CGPoint(x: 78, y: 0))
                p.move(to: CGPoint(x: 0, y: 52)); p.addLine(to: CGPoint(x: 30, y: 24))
                p.move(to: CGPoint(x: 78, y: 52)); p.addLine(to: CGPoint(x: 48, y: 24))
            }
            .stroke(Vintage.sepia.opacity(0.35), lineWidth: 1)
            HeartShape().fill(Color(red: 0.78, green: 0.20, blue: 0.20)).frame(width: 16, height: 14).offset(y: 3)
            if !note.isEmpty {
                Text(note).font(Theme.handwriting(size: 12)).foregroundStyle(Vintage.inkBrown)
                    .lineLimit(1).minimumScaleFactor(0.5).frame(width: 60).offset(y: 18)
            }
        }
    }
}

// MARK: - Stamps

/// An old postage stamp: perforated cream paper, a botanical drawing, a value and a label.
private struct VintageStamp<Picture: View>: View {
    let label: String
    let value: String
    @ViewBuilder var picture: Picture

    var body: some View {
        ZStack {
            PerforatedEdge().fill(Color(red: 0.99, green: 0.97, blue: 0.92), style: FillStyle(eoFill: true))
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(Theme.serif(10, .semibold)).foregroundStyle(Vintage.inkBrown)
                picture.frame(maxWidth: .infinity, maxHeight: .infinity)
                Text(label).font(Theme.handwriting(size: 13).weight(.semibold)).foregroundStyle(Vintage.inkBrown)
            }
            .padding(5)
            .frame(width: 52, height: 64)
            .background(Color(red: 0.93, green: 0.88, blue: 0.78))
        }
        .frame(width: 62, height: 74)
        .rotationEffect(.degrees(3))
        .shadow(color: .black.opacity(0.15), radius: 1.2, x: 0.5, y: 1)
    }
}

private struct PerforatedEdge: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        let r: CGFloat = 2.4, step: CGFloat = 7
        for x in stride(from: rect.minX + step / 2, to: rect.maxX, by: step) {
            path.addEllipse(in: CGRect(x: x - r, y: rect.minY - r, width: 2 * r, height: 2 * r))
            path.addEllipse(in: CGRect(x: x - r, y: rect.maxY - r, width: 2 * r, height: 2 * r))
        }
        for y in stride(from: rect.minY + step / 2, to: rect.maxY, by: step) {
            path.addEllipse(in: CGRect(x: rect.minX - r, y: y - r, width: 2 * r, height: 2 * r))
            path.addEllipse(in: CGRect(x: rect.maxX - r, y: y - r, width: 2 * r, height: 2 * r))
        }
        return path
    }
}

private struct LavenderSprig: View {
    let color: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach([-8.0, 0.0, 8.0], id: \.self) { x in
                VStack(spacing: 1) {
                    ForEach(0..<6) { _ in Ellipse().fill(color).frame(width: 4, height: 3) }
                    Rectangle().fill(Vintage.sage).frame(width: 1, height: 12)
                }
                .rotationEffect(.degrees(x * 1.5), anchor: .bottom)
                .offset(x: x / 2)
            }
        }
    }
}

private struct Fern: View {
    var body: some View {
        ZStack {
            Capsule().fill(Vintage.sage.mix(with: .black, by: 0.2)).frame(width: 1.2, height: 34)
            ForEach(0..<7) { i in
                HStack(spacing: 1) {
                    Ellipse().fill(Vintage.sage).frame(width: 9 - CGFloat(i), height: 3)
                    Ellipse().fill(Vintage.sage).frame(width: 9 - CGFloat(i), height: 3)
                }
                .offset(y: CGFloat(i) * 4.5 - 13)
            }
        }
    }
}

// MARK: - Paper scraps

/// Torn edges all round, for scraps ripped out of something.
private struct TornPaper: Shape {
    var seed: UInt64 = 4

    func path(in rect: CGRect) -> Path {
        var rng = SeededRandom(seed: seed)
        func jitter() -> CGFloat { CGFloat.random(in: -2...2, using: &rng) }
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 2, y: rect.minY + 2))
        for x in stride(from: rect.minX, through: rect.maxX, by: 5) { path.addLine(to: CGPoint(x: x, y: rect.minY + 2 + jitter())) }
        for y in stride(from: rect.minY, through: rect.maxY, by: 5) { path.addLine(to: CGPoint(x: rect.maxX - 2 + jitter(), y: y)) }
        for x in stride(from: rect.maxX, through: rect.minX, by: -5) { path.addLine(to: CGPoint(x: x, y: rect.maxY - 2 + jitter())) }
        for y in stride(from: rect.maxY, through: rect.minY, by: -5) { path.addLine(to: CGPoint(x: rect.minX + 2 + jitter(), y: y)) }
        path.closeSubpath()
        return path
    }
}

private struct NewspaperScrap: View {
    let headline: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(headline)
                .font(Theme.serif(13, .bold))
                .foregroundStyle(Vintage.inkBrown)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            ForEach(0..<5) { i in
                HStack(spacing: 3) {
                    Rectangle().fill(Vintage.inkBrown.opacity(0.35)).frame(height: 1.5)
                    if i % 2 == 0 { Rectangle().fill(Vintage.inkBrown.opacity(0.35)).frame(width: 16, height: 1.5) }
                }
            }
        }
        .padding(8)
        .frame(width: 92)
        .background(TornPaper(seed: 8).fill(Color(red: 0.94, green: 0.92, blue: 0.86)))
        .rotationEffect(.degrees(-4))
    }
}

private struct MusicSheet: View {
    var body: some View {
        ZStack {
            TornPaper(seed: 12).fill(Color(red: 0.95, green: 0.91, blue: 0.82))
            VStack(spacing: 10) {
                ForEach(0..<2) { _ in
                    VStack(spacing: 2.5) {
                        ForEach(0..<5) { _ in Rectangle().fill(Vintage.inkBrown.opacity(0.45)).frame(height: 0.7) }
                    }
                }
            }
            .padding(.horizontal, 6)
            ForEach(Array([(-26.0, -10.0), (-14.0, -14.0), (-2.0, -8.0), (12.0, -12.0), (24.0, 6.0), (-18.0, 10.0), (4.0, 13.0)].enumerated()), id: \.offset) { _, note in
                HStack(alignment: .bottom, spacing: 0) {
                    Ellipse().fill(Vintage.inkBrown).frame(width: 4.5, height: 3.5)
                    Rectangle().fill(Vintage.inkBrown).frame(width: 0.8, height: 10).offset(y: -2)
                }
                .offset(x: note.0, y: note.1)
            }
        }
        .frame(width: 84, height: 56)
        .rotationEffect(.degrees(5))
    }
}

private struct KraftPaper: View {
    var body: some View {
        ZStack {
            TornPaper(seed: 21).fill(LinearGradient(colors: [Vintage.kraft.mix(with: .white, by: 0.12), Vintage.kraft],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            // Crumple lines
            Path { p in
                p.move(to: CGPoint(x: 10, y: 8)); p.addLine(to: CGPoint(x: 40, y: 30)); p.addLine(to: CGPoint(x: 70, y: 20))
                p.move(to: CGPoint(x: 20, y: 60)); p.addLine(to: CGPoint(x: 45, y: 38)); p.addLine(to: CGPoint(x: 80, y: 62))
            }
            .stroke(.white.opacity(0.2), lineWidth: 1)
        }
        .frame(width: 90, height: 70)
        .rotationEffect(.degrees(-3))
    }
}

private struct PressedFlower: View {
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(Color(red: 0.97, green: 0.95, blue: 0.89)).frame(width: 58, height: 76)
            VStack(spacing: 0) {
                ZStack {
                    ForEach(0..<5) { i in
                        Ellipse().fill(Vintage.dustyRose.opacity(0.85)).frame(width: 9, height: 13)
                            .offset(y: -6).rotationEffect(.degrees(Double(i) * 72))
                    }
                    Circle().fill(Vintage.gold).frame(width: 5)
                }
                .frame(height: 26)
                Rectangle().fill(Vintage.sage).frame(width: 1.2, height: 34)
                    .overlay(Ellipse().fill(Vintage.sage).frame(width: 12, height: 5).rotationEffect(.degrees(-30)).offset(x: 6, y: 2))
            }
            .padding(.top, 8)
            Rectangle().fill(Color(red: 0.92, green: 0.88, blue: 0.80).opacity(0.85)).frame(width: 30, height: 10).offset(y: -4)
        }
        .rotationEffect(.degrees(-3))
    }
}

// MARK: - Butterflies & flowers

private struct Butterfly: View {
    let wing: Color
    let pattern: Color

    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Group {
                    Ellipse().fill(wing).frame(width: 30, height: 26).rotationEffect(.degrees(-25)).offset(x: 15, y: -8)
                    Ellipse().fill(wing).frame(width: 20, height: 18).rotationEffect(.degrees(30)).offset(x: 11, y: 11)
                    Circle().stroke(pattern, lineWidth: 1).frame(width: 9).offset(x: 17, y: -9)
                    Circle().fill(pattern).frame(width: 3).offset(x: 22, y: -14)
                    Circle().fill(pattern).frame(width: 2.5).offset(x: 12, y: 12)
                }
                .scaleEffect(x: side, y: 1)
            }
            Capsule().fill(Vintage.inkBrown).frame(width: 3.5, height: 30)
            Path { p in
                p.move(to: CGPoint(x: 0, y: 8)); p.addQuadCurve(to: CGPoint(x: -5, y: 0), control: CGPoint(x: -1, y: 2))
                p.move(to: CGPoint(x: 0, y: 8)); p.addQuadCurve(to: CGPoint(x: 5, y: 0), control: CGPoint(x: 1, y: 2))
            }
            .stroke(Vintage.inkBrown, lineWidth: 0.8)
            .frame(width: 10, height: 8)
            .offset(y: -19)
        }
    }
}

private struct DriedBunch: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(Array([-14.0, -7.0, 0.0, 7.0, 14.0].enumerated()), id: \.offset) { i, angle in
                VStack(spacing: 0.5) {
                    ForEach(0..<7) { _ in Ellipse().fill(Vintage.lavender.mix(with: .white, by: i.isMultiple(of: 2) ? 0 : 0.2)).frame(width: 4, height: 3) }
                    Rectangle().fill(Vintage.sage).frame(width: 1, height: 40)
                }
                .rotationEffect(.degrees(angle), anchor: .bottom)
            }
            SatinBow().frame(width: 24, height: 18).offset(y: -14)
        }
    }
}

private struct Daisy: View {
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(Vintage.sage).frame(width: 1.8, height: 48).offset(y: 26)
            Ellipse().fill(Vintage.sage).frame(width: 14, height: 6).rotationEffect(.degrees(-30)).offset(x: 7, y: 50)
            ZStack {
                ForEach(0..<14) { i in
                    Capsule().fill(.white).frame(width: 6, height: 17).offset(y: -10).rotationEffect(.degrees(Double(i) * 360 / 14))
                }
                Circle().fill(Color(red: 0.95, green: 0.75, blue: 0.25)).frame(width: 12)
            }
            .frame(width: 48, height: 48)
        }
    }
}

private struct SatinBow: View {
    private let satin = Color(red: 0.88, green: 0.80, blue: 0.70)

    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width / 66
            ZStack {
                ForEach([-1.0, 1.0], id: \.self) { side in
                    // Tails hang down and out from the knot
                    Capsule().fill(satin.mix(with: .black, by: 0.12)).frame(width: 7 * s, height: 20 * s)
                        .rotationEffect(.degrees(side * -28)).offset(x: side * 8 * s, y: 11 * s)
                    // Loops spread sideways, slightly tipped up
                    Ellipse().fill(LinearGradient(colors: [satin.mix(with: .white, by: 0.3), satin], startPoint: .top, endPoint: .bottom))
                        .overlay(Ellipse().stroke(satin.mix(with: .black, by: 0.15), lineWidth: 0.8))
                        .frame(width: 30 * s, height: 17 * s).rotationEffect(.degrees(side * -14)).offset(x: side * 16 * s, y: -4 * s)
                }
                RoundedRectangle(cornerRadius: 3 * s).fill(satin.mix(with: .black, by: 0.1)).frame(width: 10 * s, height: 12 * s).offset(y: -3 * s)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - Bits & pieces

private struct Typewriter: View {
    private let red = Color(red: 0.80, green: 0.22, blue: 0.18)

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(.white).frame(width: 36, height: 20).offset(y: -4)
            Capsule().fill(Color(white: 0.2)).frame(width: 60, height: 7).offset(y: 10)
            RoundedRectangle(cornerRadius: 6).fill(red).frame(width: 70, height: 34).offset(y: 16)
            VStack(spacing: 2.5) {
                ForEach(0..<3) { row in
                    HStack(spacing: 2.5) { ForEach(0..<(8 - row), id: \.self) { _ in Circle().fill(Color(white: 0.15)).frame(width: 4.5) } }
                }
            }
            .offset(y: 26)
        }
    }
}

private struct PlasterTape: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7).fill(Color(red: 0.88, green: 0.78, blue: 0.66))
            RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.94, green: 0.87, blue: 0.78)).frame(width: 18, height: 12)
            HStack(spacing: 30) {
                ForEach(0..<2) { _ in
                    VStack(spacing: 3) {
                        ForEach(0..<2) { _ in HStack(spacing: 3) { ForEach(0..<2) { _ in Circle().fill(.black.opacity(0.12)).frame(width: 1.8) } } }
                    }
                }
            }
        }
        .frame(width: 64, height: 18)
        .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
    }
}

/// A strip of typed text, cut out and stuck down: like a label-maker or a word cut from a book.
private struct TypedStrip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Vintage.typed(12))
            .foregroundStyle(Vintage.inkBrown)
            .fixedSize()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Rectangle().fill(Color(red: 0.97, green: 0.95, blue: 0.90)))
            .shadow(color: .black.opacity(0.14), radius: 0.8, x: 0.5, y: 1)
            .rotationEffect(.degrees(-1.5))
    }
}
