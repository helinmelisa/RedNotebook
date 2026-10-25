import SwiftUI

/// Portugal pack, paper scraps, lettering, more cute things and weekday badges.
struct MoreStickerView: View {
    let sticker: DrawnSticker
    var text: String = ""

    var body: some View {
        switch sticker {
        // Portugal
        case .azulejo: Azulejo().frame(width: 56, height: 56).stickerOutline(1.5)
        case .sardine: Sardine().frame(width: 84, height: 36).stickerOutline()
        case .pastelDeNata: PastelDeNata().frame(width: 56, height: 56).stickerOutline()
        case .tram: Tram().frame(width: 84, height: 60).stickerOutline()
        case .stampPortugal:
            Stamp(color: Color(red: 0.12, green: 0.45, blue: 0.30), title: "PORTUGAL", value: "€0,95") {
                Image(systemName: "sun.max.fill").font(.system(size: 18)).foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.3))
            }
        case .stampPorto:
            Stamp(color: Color(red: 0.15, green: 0.30, blue: 0.62), title: "PORTO", value: "€1,20") {
                BridgeArc().stroke(.white, lineWidth: 2).frame(width: 34, height: 16)
            }
        case .stampAntalya:
            Stamp(color: Color(red: 0.0, green: 0.55, blue: 0.62), title: "ANTALYA", value: "₺25") {
                Image(systemName: "sun.horizon.fill").font(.system(size: 17))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.35), .white)
            }
        case .stampIstanbul:
            Stamp(color: Color(red: 0.78, green: 0.12, blue: 0.15), title: "İSTANBUL", value: "₺15") {
                Image(systemName: "moon.stars.fill").font(.system(size: 16)).foregroundStyle(.white)
            }
        case .stampLisboa:
            Stamp(color: Color(red: 0.78, green: 0.20, blue: 0.20), title: "LISBOA", value: "€0,80") {
                Image(systemName: "tram.fill").font(.system(size: 16)).foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.3))
            }
        case .vianaHeart: VianaHeart().frame(width: 54, height: 50).stickerOutline()

        // Paper & scraps
        case .polaroid: Polaroid(caption: text)
        case .ticket: Ticket(text: text.isEmpty ? "ADMIT ONE" : text.uppercased())
        case .tornNote: TornNote().writing(text, size: 17, lines: 3)
        case .indexFlags: IndexFlags()
        case .gridNote: GridNote().writing(text, size: 16, lines: 3)

        // Words
        case .wordYay: Lettering(text: "yay!", color: Color(red: 0.95, green: 0.40, blue: 0.60))
        case .wordLove: Lettering(text: "love", color: Theme.red)
        case .wordOmg: Lettering(text: "omg", color: Color(red: 0.55, green: 0.40, blue: 0.80))
        case .wordThankYou: Lettering(text: "thank you", color: Color(red: 0.20, green: 0.55, blue: 0.55))
        case .wordGoodDay: Lettering(text: "good day ☀︎", color: Color(red: 0.95, green: 0.55, blue: 0.15))
        case .wordButFirstCoffee: Lettering(text: "but first,\ncoffee", color: Color(red: 0.45, green: 0.30, blue: 0.20), size: 24)

        // More cute
        case .strawberry: Strawberry().frame(width: 46, height: 52).stickerOutline()
        case .cherries: Cherries().frame(width: 54, height: 56).stickerOutline()
        case .mushroom: Mushroom().frame(width: 52, height: 52).stickerOutline()
        case .rainbow: Rainbow().frame(width: 80, height: 48).stickerOutline()
        case .catFace: CatFace().frame(width: 56, height: 50).stickerOutline()
        case .bow: Bow().frame(width: 64, height: 46).stickerOutline()

        // Weekdays
        case .weekdayMon: WeekdayBadge(text: "MON", color: Color(red: 0.93, green: 0.55, blue: 0.55))
        case .weekdayTue: WeekdayBadge(text: "TUE", color: Color(red: 0.95, green: 0.70, blue: 0.45))
        case .weekdayWed: WeekdayBadge(text: "WED", color: Color(red: 0.90, green: 0.78, blue: 0.35))
        case .weekdayThu: WeekdayBadge(text: "THU", color: Color(red: 0.55, green: 0.75, blue: 0.55))
        case .weekdayFri: WeekdayBadge(text: "FRI", color: Color(red: 0.50, green: 0.70, blue: 0.85))
        case .weekdaySat: WeekdayBadge(text: "SAT", color: Color(red: 0.65, green: 0.58, blue: 0.85))
        case .weekdaySun: WeekdayBadge(text: "SUN", color: Color(red: 0.90, green: 0.55, blue: 0.75))

        default: LifeStickerView(sticker: sticker, text: text)
        }
    }
}

// MARK: - Portugal

private let azulejoBlue = Color(red: 0.12, green: 0.30, blue: 0.66)

/// A blue-and-white tile: a quatrefoil in the middle and quarter circles in the corners.
private struct Azulejo: View {
    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width
            ZStack {
                Rectangle().fill(Color(red: 0.97, green: 0.97, blue: 0.94))
                ForEach(0..<4) { i in
                    Ellipse().fill(azulejoBlue)
                        .frame(width: s * 0.22, height: s * 0.42)
                        .offset(y: -s * 0.18)
                        .rotationEffect(.degrees(Double(i) * 90))
                }
                Circle().fill(Color(red: 0.97, green: 0.85, blue: 0.40)).frame(width: s * 0.16)
                ForEach(0..<4) { i in
                    Circle().stroke(azulejoBlue, lineWidth: s * 0.05)
                        .frame(width: s * 0.5)
                        .offset(x: (i % 2 == 0 ? -1 : 1) * s / 2, y: (i < 2 ? -1 : 1) * s / 2)
                }
                Rectangle().stroke(azulejoBlue, lineWidth: s * 0.04)
            }
            .clipShape(Rectangle())
        }
    }
}

/// A Santo António style sardine.
private struct Sardine: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack(alignment: .leading) {
                Path { p in
                    p.move(to: CGPoint(x: w * 0.78, y: h * 0.5))
                    p.addLine(to: CGPoint(x: w, y: h * 0.1))
                    p.addLine(to: CGPoint(x: w, y: h * 0.9))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.30, green: 0.45, blue: 0.70))
                Ellipse()
                    .fill(LinearGradient(colors: [Color(red: 0.30, green: 0.45, blue: 0.72), Color(red: 0.78, green: 0.85, blue: 0.92)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: w * 0.84, height: h)
                // Scales: a few little arcs
                ForEach(0..<4) { i in
                    Circle().trim(from: 0.55, to: 0.95).stroke(.white.opacity(0.6), lineWidth: 1.2)
                        .frame(width: h * 0.35)
                        .offset(x: w * (0.30 + Double(i) * 0.11), y: -h * 0.02)
                }
                Circle().fill(.white).frame(width: h * 0.24)
                    .overlay(Circle().fill(.black).frame(width: h * 0.12))
                    .offset(x: w * 0.10, y: -h * 0.08)
                Rectangle().fill(Color(red: 0.95, green: 0.35, blue: 0.40)).frame(width: 2, height: h * 0.5)
                    .offset(x: w * 0.22)
            }
        }
    }
}

private struct PastelDeNata: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.88, green: 0.66, blue: 0.32))
            Circle().stroke(Color(red: 0.75, green: 0.50, blue: 0.22), lineWidth: 2).padding(3)
            Circle().fill(Color(red: 1.0, green: 0.85, blue: 0.42)).padding(8)
            // Caramelised spots on the custard
            ForEach(Array([(-8.0, -6.0, 9.0), (6.0, -9.0, 6.0), (9.0, 6.0, 10.0), (-6.0, 9.0, 7.0), (0.0, 1.0, 5.0)].enumerated()), id: \.offset) { _, spot in
                Ellipse().fill(Color(red: 0.45, green: 0.25, blue: 0.10).opacity(0.75))
                    .frame(width: spot.2, height: spot.2 * 0.75)
                    .offset(x: spot.0, y: spot.1)
            }
        }
    }
}

/// Yellow tram, the kind that climbs Lisbon's and Porto's hills.
private struct Tram: View {
    private let yellow = Color(red: 1.0, green: 0.80, blue: 0.20)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack(alignment: .top) {
                // Trolley pole
                Path { p in
                    p.move(to: CGPoint(x: w * 0.5, y: h * 0.18))
                    p.addLine(to: CGPoint(x: w * 0.7, y: 0))
                }
                .stroke(Color(white: 0.3), lineWidth: 1.5)
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.97, green: 0.95, blue: 0.88))
                        .frame(height: h * 0.12)
                    ZStack {
                        Rectangle().fill(yellow)
                        HStack(spacing: w * 0.05) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.75, green: 0.88, blue: 0.95))
                                    .frame(width: w * 0.16, height: h * 0.22)
                            }
                        }
                        .offset(y: -h * 0.06)
                        Rectangle().fill(Color(red: 0.75, green: 0.15, blue: 0.15)).frame(height: h * 0.05)
                            .offset(y: h * 0.14)
                    }
                    .frame(height: h * 0.52)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 6, topTrailingRadius: 6))
                    HStack(spacing: w * 0.4) {
                        Circle().fill(Color(white: 0.25)).frame(width: h * 0.16)
                        Circle().fill(Color(white: 0.25)).frame(width: h * 0.16)
                    }
                    .offset(y: -h * 0.03)
                }
                .padding(.top, h * 0.16)
            }
        }
    }
}

/// A postage stamp with perforated edges.
private struct Stamp<Picture: View>: View {
    let color: Color
    let title: String
    let value: String
    @ViewBuilder var picture: Picture

    var body: some View {
        ZStack {
            Perforated().fill(Color(red: 0.99, green: 0.98, blue: 0.95), style: FillStyle(eoFill: true))
            VStack(spacing: 3) {
                picture
                Text(title).font(Theme.serif(8, .heavy)).tracking(0.5)
                    .lineLimit(1).minimumScaleFactor(0.7)
                Text(value).font(Theme.serif(8, .semibold))
            }
            .foregroundStyle(.white)
            .frame(width: 50, height: 56)
            .background(color)
        }
        .frame(width: 62, height: 70)
        .rotationEffect(.degrees(-4))
        .shadow(color: .black.opacity(0.2), radius: 1.5, x: 1, y: 1.5)
    }
}

/// A rectangle with little half-circles bitten out of every edge.
private struct Perforated: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        let r: CGFloat = 2.6, step: CGFloat = 7.5
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

/// Dom Luís bridge, as a single arch.
private struct BridgeArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.6))
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 2))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 2))
        return path
    }
}

/// Coração de Viana: a gold filigree heart.
private struct VianaHeart: View {
    private let gold = Color(red: 0.86, green: 0.66, blue: 0.20)

    var body: some View {
        ZStack {
            HeartShape().fill(LinearGradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.45), gold],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
            HeartShape().stroke(Color(red: 0.70, green: 0.48, blue: 0.10),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [0.1, 4.5]))
                .padding(5)
            HeartShape().stroke(Color(red: 0.70, green: 0.48, blue: 0.10), lineWidth: 1).padding(11)
            Image(systemName: "flame.fill").font(.system(size: 10)).foregroundStyle(gold).offset(y: -27)
        }
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.5, y: h))
        path.addCurve(to: CGPoint(x: 0, y: h * 0.3), control1: CGPoint(x: w * 0.2, y: h * 0.75), control2: CGPoint(x: 0, y: h * 0.55))
        path.addArc(center: CGPoint(x: w * 0.25, y: h * 0.28), radius: w * 0.25, startAngle: .degrees(185), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: CGPoint(x: w * 0.75, y: h * 0.28), radius: w * 0.25, startAngle: .degrees(180), endAngle: .degrees(355), clockwise: false)
        path.addCurve(to: CGPoint(x: w * 0.5, y: h), control1: CGPoint(x: w, y: h * 0.55), control2: CGPoint(x: w * 0.8, y: h * 0.75))
        return path
    }
}

// MARK: - Paper & scraps

private struct Polaroid: View {
    let caption: String

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [Color(red: 0.55, green: 0.78, blue: 0.95), Color(red: 0.98, green: 0.88, blue: 0.70)],
                               startPoint: .top, endPoint: .bottom)
                Circle().fill(Color(red: 1.0, green: 0.85, blue: 0.40)).frame(width: 14).padding(8)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 46))
                    p.addQuadCurve(to: CGPoint(x: 58, y: 42), control: CGPoint(x: 30, y: 30))
                    p.addLine(to: CGPoint(x: 58, y: 58)); p.addLine(to: CGPoint(x: 0, y: 58))
                }
                .fill(Color(red: 0.45, green: 0.65, blue: 0.45))
            }
            .frame(width: 58, height: 58)
            .clipped()
            Text(caption.isEmpty ? " " : caption)
                .font(Theme.handwriting(size: 13).weight(.semibold))
                .foregroundStyle(Theme.ink.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: 58, height: 18)
        }
        .padding(.horizontal, 6)
        .padding(.top, 6)
        .background(Color.white)
        .rotationEffect(.degrees(3))
        .shadow(color: .black.opacity(0.22), radius: 2, x: 1, y: 2)
    }
}

private struct Ticket: View {
    let text: String

    var body: some View {
        HStack(spacing: 0) {
            Text(text)
                .font(Theme.serif(11, .bold))
                .tracking(1.5)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
                .frame(width: 76)
            Rectangle().fill(.clear).frame(width: 1)
                .overlay(Rectangle().stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 2])).foregroundStyle(.white.opacity(0.8)))
            Text("Nº 25").font(Theme.serif(9, .semibold)).frame(width: 34)
        }
        .foregroundStyle(Color(red: 0.25, green: 0.30, blue: 0.32))
        .frame(height: 40)
        .background(TicketShape().fill(Color(red: 0.62, green: 0.85, blue: 0.80)))
        .shadow(color: .black.opacity(0.18), radius: 1.5, x: 1, y: 1.5)
        .rotationEffect(.degrees(-5))
    }
}

/// Rectangle with half-circle notches on the left and right.
private struct TicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(roundedRect: rect, cornerRadius: 3)
        let r: CGFloat = 6
        path.addEllipse(in: CGRect(x: rect.minX - r, y: rect.midY - r, width: 2 * r, height: 2 * r))
        path.addEllipse(in: CGRect(x: rect.maxX - r, y: rect.midY - r, width: 2 * r, height: 2 * r))
        return path.normalized(eoFill: true)
    }
}

private struct TornNote: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            TornEdge().fill(Color(red: 0.99, green: 0.97, blue: 0.88))
            VStack(spacing: 11) {
                ForEach(0..<4) { _ in Rectangle().fill(Color(red: 0.55, green: 0.70, blue: 0.85).opacity(0.5)).frame(height: 0.8) }
            }
            .padding(.top, 16).padding(.horizontal, 6)
            Rectangle().fill(Color(red: 0.95, green: 0.55, blue: 0.55).opacity(0.6)).frame(width: 0.8).padding(.leading, 14)
        }
        .frame(width: 92, height: 72)
        .shadow(color: .black.opacity(0.16), radius: 1.5, x: 1, y: 1.5)
        .rotationEffect(.degrees(-3))
    }
}

/// Paper with a ragged, torn bottom edge.
private struct TornEdge: Shape {
    func path(in rect: CGRect) -> Path {
        var rng = SeededRandom(seed: 3)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 4))
        for x in stride(from: rect.maxX, through: rect.minX, by: -4) {
            path.addLine(to: CGPoint(x: x, y: rect.maxY - CGFloat.random(in: 0...6, using: &rng)))
        }
        path.closeSubpath()
        return path
    }
}

/// See-through sticky index flags in four colours.
private struct IndexFlags: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach([Color(red: 1.0, green: 0.55, blue: 0.60), Color(red: 1.0, green: 0.80, blue: 0.35),
                     Color(red: 0.55, green: 0.85, blue: 0.60), Color(red: 0.50, green: 0.75, blue: 1.0)], id: \.self) { color in
                HStack(spacing: 0) {
                    Rectangle().fill(color.opacity(0.95)).frame(width: 14)
                    Rectangle().fill(color.opacity(0.45)).frame(width: 42)
                }
                .frame(height: 12)
                .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 2, topTrailingRadius: 2))
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

/// A small square grid sticky note, held on with a strip of tape.
private struct GridNote: View {
    var body: some View {
        ZStack(alignment: .top) {
            GridPaper(spacing: 7)
                .frame(width: 64, height: 64)
                .shadow(color: .black.opacity(0.16), radius: 1.5, x: 1, y: 1.5)
            Rectangle().fill(Color(red: 0.62, green: 0.85, blue: 0.76).opacity(0.75))
                .frame(width: 34, height: 12)
                .rotationEffect(.degrees(-6))
                .offset(y: -5)
        }
        .rotationEffect(.degrees(4))
    }
}

// MARK: - Words

/// A handwritten word with a white die-cut border.
private struct Lettering: View {
    let text: String
    let color: Color
    var size: CGFloat = 28

    var body: some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(Theme.handwriting(size: size).weight(.bold))
            .foregroundStyle(color)
            .fixedSize()
            .stickerOutline(2.5)
            .rotationEffect(.degrees(-4))
    }
}

// MARK: - More cute

private struct Strawberry: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: w * 0.5, y: h))
                    p.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.22),
                               control1: CGPoint(x: -w * 0.15, y: h * 0.55), control2: CGPoint(x: w * 0.05, y: h * 0.15))
                    p.addCurve(to: CGPoint(x: w * 0.5, y: h),
                               control1: CGPoint(x: w * 0.95, y: h * 0.15), control2: CGPoint(x: w * 1.15, y: h * 0.55))
                }
                .fill(Color(red: 0.92, green: 0.22, blue: 0.30))
                ForEach(Array([(0.35, 0.45), (0.6, 0.42), (0.48, 0.6), (0.3, 0.65), (0.66, 0.62), (0.5, 0.8)].enumerated()), id: \.offset) { _, seed in
                    Ellipse().fill(Color(red: 1.0, green: 0.88, blue: 0.45)).frame(width: 3, height: 4.5)
                        .position(x: w * seed.0, y: h * seed.1)
                }
                Image(systemName: "leaf.fill").font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.30, green: 0.65, blue: 0.35))
                    .rotationEffect(.degrees(-45))
                    .position(x: w * 0.5, y: h * 0.2)
            }
        }
    }
}

private struct Cherries: View {
    private let red = Color(red: 0.85, green: 0.12, blue: 0.22)

    var body: some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: 16, y: 38))
                p.addQuadCurve(to: CGPoint(x: 34, y: 6), control: CGPoint(x: 20, y: 14))
                p.move(to: CGPoint(x: 40, y: 40))
                p.addQuadCurve(to: CGPoint(x: 34, y: 6), control: CGPoint(x: 42, y: 18))
            }
            .stroke(Color(red: 0.40, green: 0.30, blue: 0.15), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            Image(systemName: "leaf.fill").font(.system(size: 13)).foregroundStyle(Color(red: 0.30, green: 0.65, blue: 0.35))
                .position(x: 42, y: 8)
            Circle().fill(red).frame(width: 20).position(x: 15, y: 42)
            Circle().fill(red).frame(width: 20).position(x: 40, y: 44)
            Circle().fill(.white.opacity(0.5)).frame(width: 5).position(x: 11, y: 38)
            Circle().fill(.white.opacity(0.5)).frame(width: 5).position(x: 36, y: 40)
        }
    }
}

private struct Mushroom: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6).fill(Color(red: 0.98, green: 0.93, blue: 0.82))
                .frame(width: 20, height: 24).offset(y: 12)
            UnevenRoundedRectangle(topLeadingRadius: 26, bottomLeadingRadius: 6, bottomTrailingRadius: 6, topTrailingRadius: 26)
                .fill(Color(red: 0.88, green: 0.20, blue: 0.20))
                .frame(width: 52, height: 28).offset(y: -10)
            ForEach(Array([(-14.0, -12.0, 7.0), (2.0, -18.0, 6.0), (14.0, -9.0, 8.0), (-2.0, -5.0, 5.0)].enumerated()), id: \.offset) { _, dot in
                Circle().fill(.white).frame(width: dot.2).offset(x: dot.0, y: dot.1)
            }
        }
    }
}

private struct Rainbow: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(Array([Color(red: 0.95, green: 0.40, blue: 0.40), Color(red: 1.0, green: 0.70, blue: 0.35),
                           Color(red: 1.0, green: 0.88, blue: 0.40), Color(red: 0.55, green: 0.82, blue: 0.55),
                           Color(red: 0.50, green: 0.70, blue: 0.95)].enumerated()), id: \.offset) { i, color in
                Circle().trim(from: 0.5, to: 1.0).stroke(color, lineWidth: 5)
                    .frame(width: 76 - CGFloat(i) * 10, height: 76 - CGFloat(i) * 10)
                    .offset(y: (76 - CGFloat(i) * 10) / 2)
            }
            HStack(spacing: 34) {
                Image(systemName: "cloud.fill")
                Image(systemName: "cloud.fill")
            }
            .font(.system(size: 18))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.1), radius: 1)
        }
        .frame(height: 44, alignment: .bottom)
    }
}

private struct CatFace: View {
    private let fur = Color(red: 0.98, green: 0.78, blue: 0.55)

    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 14)); p.addLine(to: CGPoint(x: 6, y: 0)); p.addLine(to: CGPoint(x: 14, y: 12))
                    p.closeSubpath()
                }
                .fill(fur)
                .frame(width: 14, height: 14)
                .scaleEffect(x: side, y: 1)
                .offset(x: side * 16, y: -16)
            }
            Ellipse().fill(fur).frame(width: 52, height: 40).offset(y: 4)
            HStack(spacing: 16) {
                Capsule().fill(Theme.ink).frame(width: 4, height: 7)
                Capsule().fill(Theme.ink).frame(width: 4, height: 7)
            }
            .offset(y: 0)
            Circle().fill(Color(red: 0.95, green: 0.55, blue: 0.60)).frame(width: 5).offset(y: 8)
            ForEach([-1.0, 1.0], id: \.self) { side in
                VStack(spacing: 3) {
                    Rectangle().frame(width: 10, height: 0.8)
                    Rectangle().frame(width: 10, height: 0.8)
                }
                .foregroundStyle(Theme.ink.opacity(0.6))
                .offset(x: side * 20, y: 9)
            }
        }
    }
}

private struct Bow: View {
    private let pink = Color(red: 0.97, green: 0.62, blue: 0.72)

    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: 8, y: 22)); p.addLine(to: CGPoint(x: 14, y: 16))
                    p.closeSubpath()
                }
                .fill(pink.mix(with: .black, by: 0.1))
                .frame(width: 14, height: 22)
                .scaleEffect(x: side, y: 1)
                .offset(x: side * 6, y: 14)
                Ellipse().fill(pink).frame(width: 28, height: 22)
                    .rotationEffect(.degrees(side * 20))
                    .offset(x: side * 16, y: -4)
            }
            Circle().fill(pink.mix(with: .black, by: 0.1)).frame(width: 12).offset(y: -3)
        }
    }
}

// MARK: - Weekdays

private struct WeekdayBadge: View {
    let text: String
    let color: Color

    var body: some View {
        // Border on the circle only, so the letters stay crisp
        Circle().fill(color)
            .frame(width: 46, height: 46)
            .stickerOutline(2)
            .overlay(Circle().stroke(.white.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [2, 2])).padding(3))
            .overlay(
                Text(text)
                    .font(Theme.serif(12, .heavy))
                    .tracking(0.5)
                    .foregroundStyle(.white)
            )
    }
}
