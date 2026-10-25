import SwiftUI

/// Antalya, more seasons and more food.
struct TravelStickerView: View {
    let sticker: DrawnSticker

    var body: some View {
        switch sticker {
        // Antalya
        case .portakal: Portakal().frame(width: 52, height: 56).stickerOutline()
        case .palmTree: PalmTree().frame(width: 58, height: 70).stickerOutline()
        case .caretta: Caretta().frame(width: 62, height: 54).stickerOutline()
        case .hadrianGate: HadrianGate().frame(width: 76, height: 50).stickerOutline()
        case .yivliMinare: YivliMinare().frame(width: 26, height: 76).stickerOutline()
        case .gulet: Gulet().frame(width: 74, height: 60).stickerOutline()
        case .nar: Nar().frame(width: 50, height: 54).stickerOutline()

        // More seasons
        case .chestnuts: Chestnuts().frame(width: 60, height: 44).stickerOutline()
        case .rainBoots: RainBoots().frame(width: 60, height: 52).stickerOutline()
        case .snowman: Snowman().frame(width: 46, height: 66).stickerOutline()
        case .mitten: Mitten().frame(width: 44, height: 56).stickerOutline()
        case .hotChocolate: HotChocolate().frame(width: 56, height: 56).stickerOutline()
        case .sakura: Sakura().frame(width: 80, height: 54).stickerOutline()
        case .watermelon: Watermelon().frame(width: 64, height: 38).stickerOutline()
        case .seashell: Seashell().frame(width: 52, height: 48).stickerOutline()
        case .icePop: IcePop().frame(width: 30, height: 64).stickerOutline()
        case .scarf: Scarf().frame(width: 52, height: 64).stickerOutline()

        // More food
        case .onigiri: Onigiri().frame(width: 54, height: 50).stickerOutline()
        case .dango: Dango().frame(width: 30, height: 74).rotationEffect(.degrees(20)).stickerOutline()
        case .matchaLatte: MatchaLatte().frame(width: 42, height: 56).stickerOutline()
        case .ramen: Ramen().frame(width: 64, height: 56).stickerOutline()
        case .baklava: Baklava().frame(width: 66, height: 42).stickerOutline()
        case .pancakes: Pancakes().frame(width: 60, height: 50).stickerOutline()
        case .cookie: Cookie().frame(width: 50, height: 50).stickerOutline()
        case .cakeSlice: CakeSlice().frame(width: 58, height: 52).stickerOutline()

        default: EmptyView()
        }
    }
}

private let leafGreen = Color(red: 0.36, green: 0.62, blue: 0.36)
private let wood = Color(red: 0.62, green: 0.42, blue: 0.26)

private struct Leaf: View {
    var color = leafGreen
    var body: some View { Ellipse().fill(color) }
}

/// A triangle with rounded-ish corners, pointing up.
private struct Peak: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.maxX * 0.95, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.maxX * 0.05, y: rect.midY))
        return path
    }
}

// MARK: - Antalya

/// Antalya's oranges: the city smells of orange blossom in spring.
private struct Portakal: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.98, green: 0.58, blue: 0.15)).frame(width: 46).offset(y: 4)
            ForEach(Array([(-8.0, -2.0), (6.0, 8.0), (10.0, -6.0), (-6.0, 14.0)].enumerated()), id: \.offset) { _, d in
                Circle().fill(.white.opacity(0.25)).frame(width: 2.5).offset(x: d.0, y: d.1)
            }
            Ellipse().fill(.white.opacity(0.35)).frame(width: 10, height: 6).rotationEffect(.degrees(-30)).offset(x: -11, y: -6)
            Capsule().fill(wood).frame(width: 3, height: 8).offset(y: -20)
            Leaf().frame(width: 18, height: 9).rotationEffect(.degrees(-25)).offset(x: 9, y: -22)
        }
    }
}

private struct PalmTree: View {
    var body: some View {
        ZStack(alignment: .top) {
            Path { p in
                p.move(to: CGPoint(x: 30, y: 70))
                p.addQuadCurve(to: CGPoint(x: 30, y: 16), control: CGPoint(x: 40, y: 44))
            }
            .stroke(wood, style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [5, 1.5]))
            ForEach(0..<6) { i in
                Leaf(color: leafGreen.mix(with: .black, by: i.isMultiple(of: 2) ? 0 : 0.12))
                    .frame(width: 30, height: 10)
                    .offset(x: 15)
                    .rotationEffect(.degrees(Double(i) * 60 - 10 + (i > 2 ? 0 : 0)), anchor: .center)
                    .offset(x: 0, y: 14)
            }
            Circle().fill(Color(red: 0.50, green: 0.35, blue: 0.20)).frame(width: 7).offset(x: 4, y: 16)
        }
    }
}

/// Caretta caretta, the loggerhead sea turtles that nest on Antalya's beaches.
private struct Caretta: View {
    private let shell = Color(red: 0.55, green: 0.48, blue: 0.28)
    private let skin = Color(red: 0.72, green: 0.66, blue: 0.48)

    var body: some View {
        ZStack {
            ForEach(Array([(-20.0, -14.0, -40.0), (20.0, -14.0, 40.0), (-18.0, 16.0, 30.0), (18.0, 16.0, -30.0)].enumerated()), id: \.offset) { _, f in
                Ellipse().fill(skin).frame(width: 18, height: 9).rotationEffect(.degrees(f.2)).offset(x: f.0, y: f.1)
            }
            Circle().fill(skin).frame(width: 16).offset(y: -24)
            Circle().fill(Theme.ink).frame(width: 2.5).offset(x: -3, y: -26)
            Circle().fill(Theme.ink).frame(width: 2.5).offset(x: 3, y: -26)
            Ellipse().fill(shell).frame(width: 40, height: 46)
            // Shell plates
            Path { p in
                p.addRoundedRect(in: CGRect(x: -7, y: -9, width: 14, height: 18), cornerSize: CGSize(width: 4, height: 4))
                for (x, y) in [(-7.0, -4.0), (7.0, -4.0), (-7.0, 6.0), (7.0, 6.0)] {
                    p.move(to: CGPoint(x: x, y: y)); p.addLine(to: CGPoint(x: x * 2.4, y: y * 1.8))
                }
            }
            .stroke(Color(red: 0.38, green: 0.32, blue: 0.18), lineWidth: 1.3)
            .offset(x: 31, y: 27)
            .frame(width: 62, height: 54)
        }
    }
}

/// Hadrian's Gate (Üç Kapılar): three arches in honey-coloured stone.
private struct HadrianGate: View {
    var body: some View {
        ZStack {
            ArchedWall().fill(Color(red: 0.90, green: 0.78, blue: 0.58), style: FillStyle(eoFill: true))
            ArchedWall().stroke(Color(red: 0.62, green: 0.48, blue: 0.30), lineWidth: 1.2)
            Rectangle().fill(Color(red: 0.80, green: 0.66, blue: 0.45)).frame(height: 5).offset(y: -18)
        }
    }

    private struct ArchedWall: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path(CGRect(x: rect.minX, y: rect.minY + rect.height * 0.12, width: rect.width, height: rect.height * 0.88))
            let archWidth = rect.width * 0.2
            for i in 0..<3 {
                let x = rect.minX + rect.width * (0.14 + Double(i) * 0.29)
                var arch = Path()
                arch.move(to: CGPoint(x: x, y: rect.maxY))
                arch.addLine(to: CGPoint(x: x, y: rect.minY + rect.height * 0.55))
                arch.addArc(center: CGPoint(x: x + archWidth / 2, y: rect.minY + rect.height * 0.55), radius: archWidth / 2,
                            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                arch.addLine(to: CGPoint(x: x + archWidth, y: rect.maxY))
                arch.closeSubpath()
                path.addPath(arch)
            }
            return path
        }
    }
}

/// The fluted brick minaret, Antalya's symbol.
private struct YivliMinare: View {
    private let brick = Color(red: 0.75, green: 0.38, blue: 0.28)

    var body: some View {
        VStack(spacing: 0) {
            Peak().fill(Color(red: 0.45, green: 0.50, blue: 0.55)).frame(width: 12, height: 14)
            Capsule().fill(brick.mix(with: .black, by: 0.15)).frame(width: 22, height: 4)
            HStack(spacing: 2) {
                ForEach(0..<4) { _ in Capsule().fill(brick).frame(width: 3.5) }
            }
            .padding(.horizontal, 2)
            .frame(width: 18, height: 48)
            .background(brick.mix(with: .black, by: 0.2))
            Rectangle().fill(Color(red: 0.88, green: 0.80, blue: 0.65)).frame(width: 24, height: 8)
        }
    }
}

/// A wooden gulet sailing off Kaleiçi.
private struct Gulet: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(alignment: .bottom, spacing: 6) {
                Triangle().fill(.white).frame(width: 22, height: 30)
                Triangle().fill(Color(red: 0.98, green: 0.96, blue: 0.90)).frame(width: 18, height: 24)
            }
            .offset(y: -20)
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 74, y: 0))
                p.addQuadCurve(to: CGPoint(x: 56, y: 14), control: CGPoint(x: 70, y: 12))
                p.addLine(to: CGPoint(x: 12, y: 14))
                p.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: 2, y: 10))
            }
            .fill(wood)
            .frame(width: 74, height: 14)
            .offset(y: -6)
            Capsule().fill(Color(red: 0.30, green: 0.65, blue: 0.80)).frame(width: 74, height: 6)
        }
    }

    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}

private struct Nar: View {
    private let red = Color(red: 0.80, green: 0.15, blue: 0.22)

    var body: some View {
        ZStack {
            Circle().fill(red).frame(width: 44).offset(y: 5)
            HStack(spacing: 0) {
                ForEach(0..<3) { _ in Peak().fill(red.mix(with: .black, by: 0.15)).frame(width: 5, height: 8) }
            }
            .offset(y: -19)
            Ellipse().fill(.white.opacity(0.3)).frame(width: 10, height: 6).rotationEffect(.degrees(-30)).offset(x: -10, y: -4)
        }
    }
}

// MARK: - More seasons

private struct Chestnuts: View {
    var body: some View {
        HStack(spacing: -6) {
            nut.rotationEffect(.degrees(-15))
            nut.rotationEffect(.degrees(12)).offset(y: 4)
        }
    }

    private var nut: some View {
        ZStack(alignment: .bottom) {
            Peak().fill(Color(red: 0.50, green: 0.28, blue: 0.16)).frame(width: 30, height: 36)
            Ellipse().fill(Color(red: 0.85, green: 0.72, blue: 0.52)).frame(width: 28, height: 9)
            Ellipse().fill(.white.opacity(0.3)).frame(width: 5, height: 9).offset(x: -6, y: -18)
        }
    }
}

private struct RainBoots: View {
    var body: some View {
        HStack(spacing: 2) {
            boot
            boot.offset(y: 2)
        }
    }

    private var boot: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 4).fill(Color(red: 1.0, green: 0.80, blue: 0.25)).frame(width: 18, height: 44)
            UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 4, bottomTrailingRadius: 8, topTrailingRadius: 8)
                .fill(Color(red: 1.0, green: 0.80, blue: 0.25)).frame(width: 28, height: 14)
            Rectangle().fill(Color(red: 0.85, green: 0.62, blue: 0.15)).frame(width: 28, height: 3)
        }
    }
}

private struct Snowman: View {
    var body: some View {
        ZStack(alignment: .top) {
            Circle().fill(.white).frame(width: 40).offset(y: 24)
            Circle().fill(.white).frame(width: 28).offset(y: 6)
            Rectangle().fill(Theme.ink).frame(width: 18, height: 10).offset(y: -2)
            Rectangle().fill(Theme.ink).frame(width: 26, height: 3).offset(y: 7)
            Capsule().fill(Theme.red).frame(width: 26, height: 5).offset(y: 30)
            Peak().fill(Color(red: 1.0, green: 0.55, blue: 0.20)).frame(width: 5, height: 10).rotationEffect(.degrees(90)).offset(x: 6, y: 18)
            HStack(spacing: 7) {
                Circle().fill(Theme.ink).frame(width: 3)
                Circle().fill(Theme.ink).frame(width: 3)
            }
            .offset(y: 15)
        }
    }
}

private struct Mitten: View {
    private let knit = Color(red: 0.85, green: 0.30, blue: 0.32)

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule().fill(knit).frame(width: 13, height: 24).rotationEffect(.degrees(-35)).offset(x: -16, y: -18)
            UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 4, topTrailingRadius: 16)
                .fill(knit).frame(width: 32, height: 46).offset(y: -8)
            Rectangle().fill(.white).frame(width: 34, height: 10)
            HStack(spacing: 4) { ForEach(0..<3) { _ in Circle().fill(.white).frame(width: 3.5) } }.offset(y: -30)
        }
    }
}

private struct HotChocolate: View {
    var body: some View {
        ZStack {
            Circle().stroke(Color(red: 0.95, green: 0.60, blue: 0.62), lineWidth: 5).frame(width: 18).offset(x: 20, y: 6)
            RoundedRectangle(cornerRadius: 7).fill(Color(red: 0.97, green: 0.68, blue: 0.70)).frame(width: 38, height: 34).offset(y: 6)
            Ellipse().fill(Color(red: 0.45, green: 0.26, blue: 0.16)).frame(width: 32, height: 8).offset(y: -9)
            ForEach(Array([(-7.0, -11.0), (3.0, -12.0), (9.0, -9.0)].enumerated()), id: \.offset) { _, m in
                RoundedRectangle(cornerRadius: 1.5).fill(.white).frame(width: 7, height: 6).offset(x: m.0, y: m.1)
            }
            ForEach([-6.0, 6.0], id: \.self) { x in
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 14)); p.addCurve(to: CGPoint(x: 0, y: 0), control1: CGPoint(x: -4, y: 9), control2: CGPoint(x: 4, y: 5))
                }
                .stroke(Theme.ink.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 2, height: 14)
                .offset(x: x, y: -24)
            }
        }
    }
}

/// A branch of cherry blossom.
private struct Sakura: View {
    var body: some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: 0, y: 46))
                p.addQuadCurve(to: CGPoint(x: 80, y: 10), control: CGPoint(x: 40, y: 40))
                p.move(to: CGPoint(x: 40, y: 32)); p.addLine(to: CGPoint(x: 50, y: 50))
            }
            .stroke(Color(red: 0.42, green: 0.30, blue: 0.24), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            ForEach(Array([(16.0, 38.0, 1.0), (36.0, 28.0, 1.2), (60.0, 18.0, 1.0), (50.0, 48.0, 0.85), (76.0, 10.0, 0.75)].enumerated()), id: \.offset) { _, f in
                Blossom().frame(width: 16 * f.2, height: 16 * f.2).position(x: f.0, y: f.1)
            }
        }
    }

    private struct Blossom: View {
        var body: some View {
            ZStack {
                ForEach(0..<5) { i in
                    Ellipse().fill(Color(red: 1.0, green: 0.78, blue: 0.84))
                        .frame(width: 7, height: 9).offset(y: -4.5).rotationEffect(.degrees(Double(i) * 72))
                }
                Circle().fill(Color(red: 0.95, green: 0.45, blue: 0.60)).frame(width: 4)
            }
        }
    }
}

private struct Watermelon: View {
    var body: some View {
        ZStack(alignment: .top) {
            HalfDisc().fill(Color(red: 0.35, green: 0.62, blue: 0.32))
            HalfDisc().fill(Color(red: 0.95, green: 0.95, blue: 0.82)).padding(.horizontal, 4).frame(height: 34)
            HalfDisc().fill(Color(red: 0.95, green: 0.38, blue: 0.42)).padding(.horizontal, 7).frame(height: 30)
            ForEach(Array([(-12.0, 8.0), (0.0, 14.0), (12.0, 8.0), (-5.0, 4.0), (6.0, 4.0)].enumerated()), id: \.offset) { _, seed in
                Ellipse().fill(Theme.ink).frame(width: 2.5, height: 4).offset(x: seed.0, y: seed.1)
            }
        }
    }

    /// The bottom half of a circle, flat edge at the top.
    private struct HalfDisc: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.midX, y: rect.minY), radius: rect.width / 2,
                        startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
            path.closeSubpath()
            return path
        }
    }
}

private struct Seashell: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Circle().trim(from: 0.5, to: 1).fill(Color(red: 0.98, green: 0.78, blue: 0.68)).frame(width: 50, height: 50).offset(y: 18)
            ForEach(0..<7) { i in
                Rectangle().fill(Color(red: 0.90, green: 0.62, blue: 0.52)).frame(width: 1.4, height: 22)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(i - 3) * 22), anchor: .bottom)
            }
            .offset(y: -6)
            RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.95, green: 0.70, blue: 0.60)).frame(width: 14, height: 8)
        }
    }
}

private struct IcePop: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.88, green: 0.75, blue: 0.55)).frame(width: 7, height: 26).offset(y: 38)
            UnevenRoundedRectangle(topLeadingRadius: 13, bottomLeadingRadius: 4, bottomTrailingRadius: 4, topTrailingRadius: 13)
                .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.62, blue: 0.72), Color(red: 0.75, green: 0.65, blue: 0.95)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 26, height: 44)
            Circle().fill(Color(red: 0.995, green: 0.985, blue: 0.955)).frame(width: 10).offset(x: 12, y: 2) // a bite
        }
    }
}

private struct Scarf: View {
    private let wool = Color(red: 0.85, green: 0.35, blue: 0.35)

    var body: some View {
        ZStack(alignment: .top) {
            Capsule().fill(wool).frame(width: 46, height: 14)
            stripes.frame(width: 14, height: 46).offset(x: 10, y: 10)
            HStack(spacing: 2) { ForEach(0..<4) { _ in Rectangle().fill(wool).frame(width: 2, height: 6) } }.offset(x: 10, y: 56)
        }
    }

    private var stripes: some View {
        VStack(spacing: 0) {
            ForEach(0..<6) { i in Rectangle().fill(i.isMultiple(of: 2) ? wool : Color(red: 0.98, green: 0.92, blue: 0.85)) }
        }
    }
}

// MARK: - More food

private struct Onigiri: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Peak().fill(.white).overlay(Peak().stroke(Color(white: 0.88), lineWidth: 1)).frame(width: 52, height: 48)
            Rectangle().fill(Color(red: 0.15, green: 0.22, blue: 0.18)).frame(width: 20, height: 18)
            HStack(spacing: 10) {
                Circle().fill(Theme.ink).frame(width: 3.5)
                Circle().fill(Theme.ink).frame(width: 3.5)
            }
            .offset(y: -24)
            Ellipse().fill(Color(red: 1.0, green: 0.65, blue: 0.70).opacity(0.7)).frame(width: 30, height: 4).offset(y: -19)
        }
    }
}

private struct Dango: View {
    var body: some View {
        ZStack {
            Capsule().fill(Color(red: 0.85, green: 0.72, blue: 0.52)).frame(width: 3, height: 72)
            VStack(spacing: -2) {
                Circle().fill(Color(red: 1.0, green: 0.72, blue: 0.78)).frame(width: 22)
                Circle().fill(Color(red: 0.99, green: 0.97, blue: 0.92)).frame(width: 22)
                Circle().fill(Color(red: 0.62, green: 0.80, blue: 0.52)).frame(width: 22)
            }
            .offset(y: -8)
        }
    }
}

private struct MatchaLatte: View {
    var body: some View {
        ZStack(alignment: .top) {
            GlassCup().fill(LinearGradient(colors: [Color(red: 0.92, green: 0.95, blue: 0.85), Color(red: 0.55, green: 0.72, blue: 0.38)],
                                           startPoint: .top, endPoint: .bottom))
                .frame(width: 38, height: 52).offset(y: 4)
            GlassCup().stroke(.white.opacity(0.9), lineWidth: 1.5).frame(width: 38, height: 52).offset(y: 4)
            Image(systemName: "leaf.fill").font(.system(size: 9)).foregroundStyle(leafGreen).offset(y: 10)
        }
    }

    private struct GlassCup: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 4, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}

private struct Ramen: View {
    var body: some View {
        ZStack {
            ForEach([-6.0, 4.0], id: \.self) { x in
                Capsule().fill(wood).frame(width: 3, height: 50).rotationEffect(.degrees(30)).offset(x: x + 10, y: -12)
            }
            Ellipse().fill(Color(red: 0.98, green: 0.88, blue: 0.60)).frame(width: 58, height: 14).offset(y: -4)
            ForEach(0..<3) { i in
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 0))
                    for x in stride(from: 4.0, through: 30, by: 4) { p.addLine(to: CGPoint(x: x, y: x.truncatingRemainder(dividingBy: 8) == 0 ? 0 : 3)) }
                }
                .stroke(Color(red: 0.95, green: 0.80, blue: 0.45), lineWidth: 1.5)
                .frame(width: 30, height: 3)
                .offset(x: -8, y: -6 + Double(i) * 2)
            }
            Circle().fill(.white).frame(width: 12).overlay(Circle().fill(Color(red: 1.0, green: 0.75, blue: 0.25)).frame(width: 6)).offset(x: 14, y: -5)
            BowlShape().fill(Theme.red).frame(width: 60, height: 28).offset(y: 12)
            Capsule().fill(.white.opacity(0.85)).frame(width: 42, height: 2.5).offset(y: 10)
        }
    }

    private struct BowlShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY * 1.6))
            return path
        }
    }
}

private struct Baklava: View {
    var body: some View {
        HStack(spacing: -10) {
            ForEach(0..<3) { i in
                ZStack {
                    Rectangle().fill(Color(red: 0.92, green: 0.70, blue: 0.32))
                        .overlay(VStack(spacing: 3) { ForEach(0..<4) { _ in Rectangle().fill(Color(red: 0.98, green: 0.85, blue: 0.55)).frame(height: 1.2) } })
                        .frame(width: 26, height: 26)
                        .rotationEffect(.degrees(45))
                    Circle().fill(Color(red: 0.45, green: 0.68, blue: 0.30)).frame(width: 6)
                }
                .offset(y: i == 1 ? -4 : 2)
            }
        }
    }
}

private struct Pancakes: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: -3) {
                ForEach(0..<3) { _ in
                    Capsule().fill(Color(red: 0.90, green: 0.68, blue: 0.40))
                        .overlay(Capsule().stroke(Color(red: 0.78, green: 0.52, blue: 0.28), lineWidth: 1))
                        .frame(width: 54, height: 13)
                }
            }
            .offset(y: 12)
            Capsule().fill(Color(red: 0.70, green: 0.38, blue: 0.15).opacity(0.85)).frame(width: 40, height: 7).offset(y: 10)
            Capsule().fill(Color(red: 0.70, green: 0.38, blue: 0.15).opacity(0.85)).frame(width: 5, height: 14).offset(x: -12, y: 12)
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 1.0, green: 0.92, blue: 0.55)).frame(width: 12, height: 8).offset(y: 4)
        }
    }
}

private struct Cookie: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.88, green: 0.66, blue: 0.38))
            ForEach(Array([(-10.0, -8.0), (8.0, -10.0), (-2.0, 2.0), (12.0, 6.0), (-12.0, 10.0), (2.0, 13.0)].enumerated()), id: \.offset) { _, chip in
                RoundedRectangle(cornerRadius: 1.5).fill(Color(red: 0.32, green: 0.18, blue: 0.10)).frame(width: 6, height: 5).offset(x: chip.0, y: chip.1)
            }
        }
    }
}

private struct CakeSlice: View {
    var body: some View {
        ZStack(alignment: .top) {
            Wedge().fill(Color(red: 0.99, green: 0.94, blue: 0.86)).frame(width: 56, height: 40).offset(y: 12)
            VStack(spacing: 8) {
                Rectangle().fill(Color(red: 1.0, green: 0.70, blue: 0.78)).frame(height: 4)
                Rectangle().fill(Color(red: 1.0, green: 0.70, blue: 0.78)).frame(height: 4)
            }
            .frame(width: 56)
            .mask(Wedge().frame(width: 56, height: 40))
            .offset(y: 24)
            Circle().fill(Theme.red).frame(width: 12).offset(x: 14, y: 0)
            Image(systemName: "leaf.fill").font(.system(size: 7)).foregroundStyle(leafGreen).offset(x: 17, y: -5)
        }
    }

    /// A slice seen from the side: tall at the back, pointed at the front.
    private struct Wedge: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.35))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}
