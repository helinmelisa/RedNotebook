import SwiftUI

/// More Türkiye, vintage, animals, seasons, work, self-care, and words in Portuguese and Turkish.
struct BatchStickerView: View {
    let sticker: DrawnSticker

    var body: some View {
        switch sticker {
        // Türkiye
        case .vapur: Vapur().frame(width: 76, height: 44).stickerOutline()
        case .fairyChimney: FairyChimneys().frame(width: 70, height: 56).stickerOutline()
        case .ayran: Ayran().frame(width: 36, height: 56).stickerOutline()
        case .mosque: MosqueSkyline().frame(width: 80, height: 50).stickerOutline()
        case .streetCat: StreetCat().frame(width: 56, height: 54).stickerOutline()
        case .lahmacun: Lahmacun().frame(width: 60, height: 60).stickerOutline()

        // Vintage
        case .vintageKey: VintageKey().frame(width: 76, height: 32).rotationEffect(.degrees(-20)).stickerOutline()
        case .pocketWatch: PocketWatch().frame(width: 52, height: 64).stickerOutline()
        case .quillInk: QuillInk().frame(width: 52, height: 66).stickerOutline()
        case .floralTeacup: FloralTeacup().frame(width: 64, height: 46).stickerOutline()
        case .vintageCamera: VintageCamera().frame(width: 66, height: 46).stickerOutline()
        case .cassette: Cassette().frame(width: 72, height: 46).stickerOutline()

        // Animals
        case .sleepyCat: SleepyCat().frame(width: 70, height: 44).stickerOutline()
        case .puppy: Puppy().frame(width: 56, height: 52).stickerOutline()
        case .panda: Panda().frame(width: 56, height: 52).stickerOutline()
        case .fox: Fox().frame(width: 58, height: 52).stickerOutline()
        case .hedgehog: Hedgehog().frame(width: 64, height: 44).stickerOutline()
        case .whale: Whale().frame(width: 72, height: 46).stickerOutline()

        // Seasons
        case .acorn: Acorn().frame(width: 38, height: 50).stickerOutline()
        case .umbrella: RainUmbrella().frame(width: 60, height: 62).stickerOutline()
        case .kite: Kite().frame(width: 48, height: 74).stickerOutline()
        case .snowGlobe: SnowGlobe().frame(width: 54, height: 62).stickerOutline()
        case .beachBall: BeachBall().frame(width: 50, height: 50).stickerOutline()
        case .candyCane: CandyCane().frame(width: 34, height: 64).stickerOutline()

        // Work
        case .calendarPage: CalendarPage().frame(width: 50, height: 56).stickerOutline()
        case .clipboard: Clipboard().frame(width: 46, height: 60).stickerOutline()
        case .pomodoro: Pomodoro().frame(width: 52, height: 54).stickerOutline()
        case .deskLamp: DeskLamp().frame(width: 56, height: 62).stickerOutline()
        case .stickyStack: StickyStack().frame(width: 56, height: 56)
        case .briefcase: Briefcase().frame(width: 60, height: 48).stickerOutline()

        // Self-care
        case .sheetMask: SheetMask().frame(width: 50, height: 58).stickerOutline()
        case .serum: Serum().frame(width: 30, height: 64).stickerOutline()
        case .yoga: symbol("figure.yoga", Color(red: 0.62, green: 0.50, blue: 0.80))
        case .sleepMask: SleepMask().frame(width: 72, height: 34).stickerOutline()
        case .bathBomb: BathBomb().frame(width: 48, height: 48).stickerOutline()
        case .youGotThis: Word(text: "you got this", color: Color(red: 0.90, green: 0.45, blue: 0.55))

        // Words
        case .bomDia: Word(text: "bom dia ☀︎", color: PortugueseHolidays.color)
        case .saudadeWord: Word(text: "saudade", color: Color(red: 0.18, green: 0.30, blue: 0.58))
        case .gunaydin: Word(text: "günaydın ☀︎", color: Color(red: 0.80, green: 0.15, blue: 0.20))
        case .cokGuzel: Word(text: "çok güzel ♡", color: Color(red: 0.80, green: 0.15, blue: 0.20))

        default: EmptyView()
        }
    }

    private func symbol(_ name: String, _ color: Color) -> some View {
        Image(systemName: name).font(.system(size: 44)).foregroundStyle(color).stickerOutline()
    }
}

private let blush = Color(red: 1.0, green: 0.65, blue: 0.70)
private let ink = Color(red: 0.18, green: 0.18, blue: 0.22)
private let brass = Color(red: 0.80, green: 0.64, blue: 0.32)

private struct Eyes: View {
    var gap: CGFloat = 14
    var body: some View {
        HStack(spacing: gap) { Circle().fill(ink).frame(width: 5); Circle().fill(ink).frame(width: 5) }
    }
}

private struct Word: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(Theme.handwriting(size: 28).weight(.bold))
            .foregroundStyle(color)
            .fixedSize()
            .stickerOutline(2.5)
            .rotationEffect(.degrees(-4))
    }
}

private struct Tri: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); p.move(to: CGPoint(x: r.midX, y: r.minY)); p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY)); p.closeSubpath(); return p
    }
}

// MARK: - Türkiye

/// The white-and-orange İstanbul ferry.
private struct Vapur: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule().fill(Color(red: 0.35, green: 0.62, blue: 0.82)).frame(width: 76, height: 6)
            UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 4).fill(Color(red: 0.20, green: 0.22, blue: 0.28))
                .frame(width: 66, height: 12).offset(y: -5)
            Rectangle().fill(.white).frame(width: 52, height: 12).offset(x: 2, y: -17)
                .overlay(HStack(spacing: 4) { ForEach(0..<6) { _ in Rectangle().fill(Color(red: 0.55, green: 0.75, blue: 0.90)).frame(width: 4, height: 5) } }.offset(x: 2, y: -17))
            Rectangle().fill(.white).frame(width: 30, height: 8).offset(x: 2, y: -27)
            Rectangle().fill(Color(red: 0.95, green: 0.55, blue: 0.15)).frame(width: 7, height: 10).offset(x: 4, y: -34)
        }
    }
}

private struct FairyChimneys: View {
    private let stone = Color(red: 0.90, green: 0.74, blue: 0.56)
    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(Array([(-22.0, 40.0), (0.0, 54.0), (20.0, 44.0)].enumerated()), id: \.offset) { i, c in
                VStack(spacing: -2) {
                    Ellipse().fill(stone.mix(with: .black, by: 0.25)).frame(width: 18, height: 9)
                    Capsule().fill(stone.mix(with: .white, by: i == 1 ? 0.1 : 0)).frame(width: 16, height: c.1 - 8)
                }
                .offset(x: c.0)
            }
            Rectangle().fill(stone.mix(with: .black, by: 0.1)).frame(width: 70, height: 6)
        }
    }
}

private struct Ayran: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 4).fill(.white).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(white: 0.82), lineWidth: 1))
                .frame(width: 30, height: 48).offset(y: 8)
            Ellipse().fill(.white).overlay(Ellipse().stroke(Color(white: 0.85), lineWidth: 1)).frame(width: 28, height: 8).offset(y: 5)
            Capsule().fill(Color(red: 0.25, green: 0.50, blue: 0.80)).frame(width: 30, height: 8).offset(y: 28)
        }
    }
}

private struct MosqueSkyline: View {
    private let shade = Color(red: 0.35, green: 0.38, blue: 0.55)
    var body: some View {
        ZStack(alignment: .bottom) {
            Circle().fill(Color(red: 1.0, green: 0.78, blue: 0.45)).frame(width: 26).offset(x: 24, y: -24)
            HStack(alignment: .bottom, spacing: 3) {
                minaret
                ZStack(alignment: .bottom) {
                    Circle().trim(from: 0.5, to: 1).fill(shade).frame(width: 40, height: 40).offset(y: 20)
                    Rectangle().fill(shade).frame(width: 46, height: 14)
                }
                .frame(height: 34)
                minaret
            }
        }
    }
    private var minaret: some View {
        VStack(spacing: 0) { Tri().fill(shade).frame(width: 5, height: 8); Rectangle().fill(shade).frame(width: 4, height: 34) }
    }
}

private struct StreetCat: View {
    private let fur = Color(red: 0.85, green: 0.60, blue: 0.35)
    var body: some View {
        ZStack {
            Path { p in p.move(to: CGPoint(x: 0, y: 30)); p.addQuadCurve(to: CGPoint(x: 8, y: 0), control: CGPoint(x: 12, y: 22)) }
                .stroke(fur, style: StrokeStyle(lineWidth: 5, lineCap: .round)).frame(width: 12, height: 30).offset(x: 24, y: 2)
            Ellipse().fill(fur).frame(width: 40, height: 28).offset(y: 12)
            ForEach([-1.0, 1.0], id: \.self) { s in Tri().fill(fur).frame(width: 12, height: 12).offset(x: s * 10, y: -18) }
            Circle().fill(fur).frame(width: 32).offset(y: -6)
            Circle().fill(Color(white: 0.95)).frame(width: 14).offset(x: -6, y: -2)  // a white patch
            Eyes(gap: 10).offset(y: -8)
            Ellipse().fill(blush).frame(width: 4, height: 3).offset(y: -2)
        }
    }
}

private struct Lahmacun: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.92, green: 0.78, blue: 0.55))
            Circle().fill(Color(red: 0.78, green: 0.32, blue: 0.22)).padding(5)
            ForEach(Array([(-10.0, -8.0), (8.0, -12.0), (12.0, 8.0), (-8.0, 12.0), (0.0, 0.0)].enumerated()), id: \.offset) { _, p in
                Image(systemName: "leaf.fill").font(.system(size: 9)).foregroundStyle(Color(red: 0.40, green: 0.68, blue: 0.35)).offset(x: p.0, y: p.1)
            }
            Ellipse().fill(Color(red: 1.0, green: 0.92, blue: 0.40)).frame(width: 10, height: 5).rotationEffect(.degrees(30)).offset(x: 14, y: -2) // lemon
        }
    }
}

// MARK: - Vintage

private struct VintageKey: View {
    var body: some View {
        HStack(spacing: 0) {
            Circle().stroke(brass, lineWidth: 5).frame(width: 24)
            Rectangle().fill(brass).frame(width: 42, height: 5)
            VStack(spacing: 2) { Rectangle().fill(brass).frame(width: 6, height: 8); Rectangle().fill(brass).frame(width: 6, height: 5) }.offset(y: 6)
        }
    }
}

private struct PocketWatch: View {
    var body: some View {
        ZStack {
            Circle().stroke(brass, lineWidth: 3).frame(width: 12).offset(y: -27)
            Circle().fill(brass).frame(width: 48).offset(y: 6)
            Circle().fill(Color(red: 0.98, green: 0.95, blue: 0.88)).frame(width: 38).offset(y: 6)
            ForEach(0..<12) { i in
                Rectangle().fill(ink).frame(width: 1, height: i % 3 == 0 ? 4 : 2).offset(y: -15).rotationEffect(.degrees(Double(i) * 30)).offset(y: 6)
            }
            Rectangle().fill(ink).frame(width: 1.5, height: 11).offset(y: -5.5).rotationEffect(.degrees(-50), anchor: .bottom).offset(y: 6)
            Rectangle().fill(ink).frame(width: 1.5, height: 14).offset(y: -7).rotationEffect(.degrees(60), anchor: .bottom).offset(y: 6)
        }
    }
}

private struct QuillInk: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(systemName: "leaf.fill").font(.system(size: 40)).foregroundStyle(Color(red: 0.92, green: 0.88, blue: 0.80))
                .rotationEffect(.degrees(-60)).offset(x: 10, y: -24)
            RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.18, green: 0.22, blue: 0.35)).frame(width: 30, height: 26)
            Rectangle().fill(Color(red: 0.30, green: 0.32, blue: 0.40)).frame(width: 16, height: 6).offset(y: -26)
            Rectangle().fill(Color(red: 0.95, green: 0.92, blue: 0.85)).frame(width: 20, height: 9).offset(y: -9)
        }
    }
}

private struct FloralTeacup: View {
    var body: some View {
        ZStack {
            Ellipse().fill(.white).overlay(Ellipse().stroke(brass, lineWidth: 1.5)).frame(width: 62, height: 12).offset(y: 16)
            Circle().stroke(.white, lineWidth: 4).overlay(Circle().stroke(brass, lineWidth: 1)).frame(width: 14).offset(x: 20, y: 0)
            UnevenRoundedRectangle(bottomLeadingRadius: 14, bottomTrailingRadius: 14).fill(.white)
                .overlay(UnevenRoundedRectangle(bottomLeadingRadius: 14, bottomTrailingRadius: 14).stroke(brass, lineWidth: 1.2))
                .frame(width: 38, height: 24).offset(y: 2)
            HStack(spacing: 6) {
                ForEach(0..<3) { _ in Circle().fill(Color(red: 0.92, green: 0.62, blue: 0.68)).frame(width: 6) }
            }
            .offset(y: 3)
            Rectangle().fill(brass).frame(width: 38, height: 1.5).offset(y: -9)
        }
    }
}

private struct VintageCamera: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.25, green: 0.22, blue: 0.22)).frame(width: 18, height: 8).offset(x: -18, y: -20)
            RoundedRectangle(cornerRadius: 6).fill(Color(red: 0.62, green: 0.45, blue: 0.32)).frame(width: 66, height: 38).offset(y: 4)
            Rectangle().fill(Color(white: 0.85)).frame(width: 66, height: 8).offset(y: -9)
            Circle().fill(Color(white: 0.85)).frame(width: 28).offset(y: 6)
            Circle().fill(ink).frame(width: 20).offset(y: 6)
            Circle().fill(.white.opacity(0.4)).frame(width: 6).offset(x: -3, y: 2)
        }
    }
}

private struct Cassette: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.92, green: 0.55, blue: 0.40))
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.98, green: 0.94, blue: 0.85)).frame(width: 56, height: 22).offset(y: -5)
            HStack(spacing: 16) { ForEach(0..<2) { _ in Circle().fill(ink).frame(width: 12).overlay(Circle().fill(.white).frame(width: 4)) } }.offset(y: -5)
            Text("mix ♡").font(Theme.handwriting(size: 11)).foregroundStyle(ink).offset(y: -15)
            Rectangle().fill(Color(red: 0.80, green: 0.45, blue: 0.32)).frame(width: 40, height: 8).offset(y: 16)
        }
    }
}

// MARK: - Animals

private struct SleepyCat: View {
    private let fur = Color(red: 0.55, green: 0.55, blue: 0.60)
    var body: some View {
        ZStack {
            Ellipse().fill(fur).frame(width: 64, height: 32).offset(y: 6)
            Capsule().fill(fur.mix(with: .black, by: 0.1)).frame(width: 40, height: 9).offset(x: 6, y: 18)
            ForEach([-1.0, 1.0], id: \.self) { s in Tri().fill(fur).frame(width: 10, height: 10).offset(x: -18 + s * 7, y: -10) }
            HStack(spacing: 8) {
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.3).frame(width: 6)
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.3).frame(width: 6)
            }
            .offset(x: -18, y: 2)
            Text("z").font(Theme.handwriting(size: 14).weight(.bold)).foregroundStyle(Color(red: 0.45, green: 0.40, blue: 0.75)).offset(x: -34, y: -14)
        }
    }
}

private struct Puppy: View {
    private let fur = Color(red: 0.95, green: 0.85, blue: 0.68)
    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { s in
                Ellipse().fill(Color(red: 0.72, green: 0.52, blue: 0.35)).frame(width: 14, height: 26).rotationEffect(.degrees(s * 18)).offset(x: s * 20, y: 0)
            }
            Circle().fill(fur).frame(width: 44)
            Eyes(gap: 12).offset(y: -2)
            Ellipse().fill(ink).frame(width: 9, height: 6).offset(y: 6)
            HStack(spacing: 24) { Ellipse().fill(blush).frame(width: 7, height: 4); Ellipse().fill(blush).frame(width: 7, height: 4) }.offset(y: 7)
        }
    }
}

private struct Panda: View {
    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { s in Circle().fill(ink).frame(width: 16).offset(x: s * 17, y: -16) }
            Circle().fill(.white).frame(width: 46)
            ForEach([-1.0, 1.0], id: \.self) { s in
                Ellipse().fill(ink).frame(width: 12, height: 15).rotationEffect(.degrees(s * -25)).offset(x: s * 9, y: -1)
                Circle().fill(.white).frame(width: 4).offset(x: s * 9, y: -2)
            }
            Ellipse().fill(ink).frame(width: 7, height: 5).offset(y: 9)
            HStack(spacing: 28) { Ellipse().fill(blush).frame(width: 7, height: 4); Ellipse().fill(blush).frame(width: 7, height: 4) }.offset(y: 8)
        }
    }
}

private struct Fox: View {
    private let orange = Color(red: 0.95, green: 0.52, blue: 0.20)
    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { s in Tri().fill(orange).frame(width: 16, height: 18).rotationEffect(.degrees(s * 12)).offset(x: s * 15, y: -18) }
            Tri().fill(orange).frame(width: 52, height: 40).rotationEffect(.degrees(180)).offset(y: 4)
            ForEach([-1.0, 1.0], id: \.self) { s in Tri().fill(.white).frame(width: 22, height: 20).rotationEffect(.degrees(180)).offset(x: s * 8, y: 10) }
            Eyes(gap: 14).offset(y: -2)
            Circle().fill(ink).frame(width: 6).offset(y: 20)
        }
    }
}

private struct Hedgehog: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color(red: 0.55, green: 0.40, blue: 0.30)).frame(width: 58, height: 36).offset(x: 4, y: 2)
            ForEach(0..<9) { i in
                Tri().fill(Color(red: 0.45, green: 0.32, blue: 0.24)).frame(width: 9, height: 10)
                    .rotationEffect(.degrees(Double(i) * 22 - 80)).offset(y: -18).rotationEffect(.degrees(Double(i) * 22 - 80)).offset(x: 4, y: 2)
            }
            Ellipse().fill(Color(red: 0.95, green: 0.85, blue: 0.70)).frame(width: 26, height: 22).offset(x: -18, y: 6)
            Circle().fill(ink).frame(width: 4).offset(x: -18, y: 3)
            Circle().fill(ink).frame(width: 5).offset(x: -30, y: 8)
        }
    }
}

private struct Whale: View {
    private let blue = Color(red: 0.45, green: 0.65, blue: 0.90)
    var body: some View {
        ZStack {
            Ellipse().fill(blue).frame(width: 54, height: 32).offset(x: -4, y: 6)
            Ellipse().fill(blue.mix(with: .white, by: 0.5)).frame(width: 36, height: 12).offset(x: -6, y: 15)
            Path { p in p.move(to: CGPoint(x: 0, y: 10)); p.addLine(to: CGPoint(x: 18, y: 0)); p.addLine(to: CGPoint(x: 14, y: 12)); p.addLine(to: CGPoint(x: 18, y: 24)); p.closeSubpath() }
                .fill(blue).frame(width: 18, height: 24).offset(x: 28, y: 0)
            Circle().fill(ink).frame(width: 4).offset(x: -18, y: 4)
            Ellipse().fill(blush).frame(width: 6, height: 3).offset(x: -18, y: 10)
            ForEach([-6.0, 0.0, 6.0], id: \.self) { x in
                Capsule().fill(blue.mix(with: .white, by: 0.4)).frame(width: 2.5, height: 10).rotationEffect(.degrees(x * 4)).offset(x: -6 + x, y: -16)
            }
        }
    }
}

// MARK: - Seasons

private struct Acorn: View {
    var body: some View {
        ZStack(alignment: .top) {
            Ellipse().fill(Color(red: 0.75, green: 0.50, blue: 0.25)).frame(width: 28, height: 36).offset(y: 12)
            UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 4, bottomTrailingRadius: 4, topTrailingRadius: 14)
                .fill(Color(red: 0.50, green: 0.35, blue: 0.20)).frame(width: 34, height: 16).offset(y: 4)
            Capsule().fill(Color(red: 0.42, green: 0.30, blue: 0.18)).frame(width: 3, height: 8)
        }
    }
}

private struct RainUmbrella: View {
    var body: some View {
        ZStack(alignment: .top) {
            Circle().trim(from: 0.5, to: 1).fill(Color(red: 0.95, green: 0.78, blue: 0.30)).frame(width: 58, height: 58).offset(y: 6)
            Rectangle().fill(ink).frame(width: 2, height: 30).offset(y: 34)
            Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 2).frame(width: 9).offset(x: 4.5, y: 60)
            ForEach([-22.0, 0.0, 22.0], id: \.self) { x in
                Image(systemName: "drop.fill").font(.system(size: 7)).foregroundStyle(Color(red: 0.45, green: 0.65, blue: 0.95)).offset(x: x, y: -4)
            }
        }
    }
}

private struct Kite: View {
    var body: some View {
        ZStack(alignment: .top) {
            Path { p in p.move(to: CGPoint(x: 24, y: 0)); p.addLine(to: CGPoint(x: 48, y: 22)); p.addLine(to: CGPoint(x: 24, y: 52)); p.addLine(to: CGPoint(x: 0, y: 22)); p.closeSubpath() }
                .fill(LinearGradient(colors: [Color(red: 0.95, green: 0.45, blue: 0.50), Color(red: 0.55, green: 0.70, blue: 0.95)], startPoint: .top, endPoint: .bottom))
                .frame(width: 48, height: 52)
            Path { p in p.move(to: CGPoint(x: 24, y: 52)); p.addCurve(to: CGPoint(x: 20, y: 74), control1: CGPoint(x: 34, y: 60), control2: CGPoint(x: 10, y: 66)) }
                .stroke(ink.opacity(0.6), lineWidth: 1).frame(width: 48, height: 74)
            ForEach(Array([(26.0, 60.0), (16.0, 68.0)].enumerated()), id: \.offset) { _, b in
                Capsule().fill(Color(red: 1.0, green: 0.82, blue: 0.35)).frame(width: 8, height: 4).position(x: b.0, y: b.1)
            }
            .frame(width: 48, height: 74)
        }
    }
}

private struct SnowGlobe: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Circle().fill(Color(red: 0.82, green: 0.90, blue: 0.98).opacity(0.9)).overlay(Circle().stroke(.white, lineWidth: 2)).frame(width: 50).offset(y: -12)
            Tri().fill(Color(red: 0.25, green: 0.52, blue: 0.35)).frame(width: 20, height: 24).offset(y: -18)
            ForEach(Array([(-14.0, -40.0), (10.0, -46.0), (16.0, -30.0), (-10.0, -24.0), (0.0, -52.0)].enumerated()), id: \.offset) { _, f in
                Circle().fill(.white).frame(width: 3).offset(x: f.0, y: f.1)
            }
            UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 6, bottomTrailingRadius: 6, topTrailingRadius: 4)
                .fill(Color(red: 0.62, green: 0.40, blue: 0.28)).frame(width: 42, height: 14)
        }
    }
}

private struct BeachBall: View {
    private let colors = [Color(red: 0.95, green: 0.35, blue: 0.35), Color(red: 1.0, green: 0.85, blue: 0.30),
                          Color(red: 0.35, green: 0.62, blue: 0.95), .white, Color(red: 0.45, green: 0.80, blue: 0.50), .white]

    var body: some View {
        ZStack {
            ForEach(colors.indices, id: \.self) { i in
                Wedge(start: .degrees(Double(i) * 60), end: .degrees(Double(i + 1) * 60)).fill(colors[i])
            }
            Circle().stroke(Color(white: 0.85), lineWidth: 1)
            Circle().fill(.white).frame(width: 10)
        }
    }

    private struct Wedge: Shape {
        let start: Angle, end: Angle
        func path(in rect: CGRect) -> Path {
            var p = Path()
            let c = CGPoint(x: rect.midX, y: rect.midY)
            p.move(to: c)
            p.addArc(center: c, radius: rect.width / 2, startAngle: start, endAngle: end, clockwise: false)
            p.closeSubpath()
            return p
        }
    }
}

private struct CandyCane: View {
    var body: some View {
        ZStack {
            Path { p in p.move(to: CGPoint(x: 10, y: 64)); p.addLine(to: CGPoint(x: 10, y: 16)); p.addArc(center: CGPoint(x: 20, y: 16), radius: 10, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
                .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
            Path { p in p.move(to: CGPoint(x: 10, y: 64)); p.addLine(to: CGPoint(x: 10, y: 16)); p.addArc(center: CGPoint(x: 20, y: 16), radius: 10, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
                .stroke(Theme.red, style: StrokeStyle(lineWidth: 8, lineCap: .butt, dash: [5, 5]))
        }
    }
}

// MARK: - Work

private struct CalendarPage: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Theme.red).frame(height: 14)
                .overlay(Text("MON").font(Theme.serif(8, .bold)).foregroundStyle(.white))
            Text("\(Calendar.current.component(.day, from: .now))").font(Theme.serif(24, .bold)).foregroundStyle(ink)
                .frame(maxWidth: .infinity, maxHeight: .infinity).background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(alignment: .top) { HStack(spacing: 18) { Capsule().fill(Color(white: 0.6)).frame(width: 3, height: 8); Capsule().fill(Color(white: 0.6)).frame(width: 3, height: 8) }.offset(y: -4) }
    }
}

private struct Clipboard: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.72, green: 0.52, blue: 0.35)).frame(width: 46, height: 58).offset(y: 2)
            Rectangle().fill(.white).frame(width: 36, height: 44).offset(y: 12)
            VStack(alignment: .leading, spacing: 5) {
                ForEach(0..<3) { i in
                    HStack(spacing: 3) {
                        Image(systemName: i < 2 ? "checkmark.square" : "square").font(.system(size: 7)).foregroundStyle(Theme.red)
                        Rectangle().fill(ink.opacity(0.5)).frame(width: 18, height: 1.5)
                    }
                }
            }
            .offset(y: 20)
            RoundedRectangle(cornerRadius: 2).fill(Color(white: 0.7)).frame(width: 18, height: 8)
        }
    }
}

private struct Pomodoro: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.90, green: 0.25, blue: 0.22)).frame(width: 48).offset(y: 4)
            Image(systemName: "leaf.fill").font(.system(size: 12)).foregroundStyle(Color(red: 0.35, green: 0.62, blue: 0.32)).offset(y: -20)
            Rectangle().fill(.white.opacity(0.8)).frame(width: 30, height: 1.5).offset(y: 4)
            ForEach(0..<5) { i in Rectangle().fill(.white.opacity(0.8)).frame(width: 1, height: 4).offset(x: CGFloat(i - 2) * 7, y: 1) }
            Text("25").font(Theme.serif(10, .bold)).foregroundStyle(.white).offset(y: 14)
        }
    }
}

private struct DeskLamp: View {
    private let green = Color(red: 0.30, green: 0.52, blue: 0.40)
    var body: some View {
        ZStack {
            Tri().fill(Color(red: 1.0, green: 0.92, blue: 0.55).opacity(0.6)).frame(width: 36, height: 30).offset(x: 10, y: 14)
            Capsule().fill(brass).frame(width: 3, height: 34).rotationEffect(.degrees(20)).offset(x: -10, y: 8)
            Capsule().fill(brass).frame(width: 3, height: 24).rotationEffect(.degrees(-50)).offset(x: -6, y: -14)
            Circle().trim(from: 0.5, to: 1).fill(green).frame(width: 26, height: 26).rotationEffect(.degrees(35)).offset(x: 6, y: -16)
            Capsule().fill(green.mix(with: .black, by: 0.2)).frame(width: 30, height: 6).offset(x: -12, y: 28)
        }
    }
}

private struct StickyStack: View {
    var body: some View {
        ZStack {
            ForEach(Array([Color(red: 0.62, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.78, blue: 0.82), Color(red: 1.0, green: 0.92, blue: 0.55)].enumerated()), id: \.offset) { i, c in
                Rectangle().fill(c).frame(width: 44, height: 44)
                    .rotationEffect(.degrees(Double(i) * 6 - 6)).offset(x: CGFloat(i) * 2, y: CGFloat(-i) * 2)
                    .shadow(color: .black.opacity(0.12), radius: 1, x: 0.5, y: 1)
            }
            Text("ideas").font(Theme.handwriting(size: 15)).foregroundStyle(ink).rotationEffect(.degrees(6)).offset(x: 4, y: -4)
        }
    }
}

private struct Briefcase: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 4).stroke(Color(red: 0.42, green: 0.28, blue: 0.20), lineWidth: 3).frame(width: 20, height: 12)
            RoundedRectangle(cornerRadius: 6).fill(Color(red: 0.58, green: 0.38, blue: 0.26)).frame(width: 58, height: 38).offset(y: 8)
            Rectangle().fill(Color(red: 0.48, green: 0.30, blue: 0.20)).frame(width: 58, height: 3).offset(y: 22)
            RoundedRectangle(cornerRadius: 1.5).fill(brass).frame(width: 10, height: 6).offset(y: 20)
        }
    }
}

// MARK: - Self-care

private struct SheetMask: View {
    var body: some View {
        ZStack {
            Ellipse().fill(.white).overlay(Ellipse().stroke(Color(white: 0.85), lineWidth: 1)).frame(width: 46, height: 56)
            HStack(spacing: 12) { Capsule().fill(Color(white: 0.9)).frame(width: 10, height: 5); Capsule().fill(Color(white: 0.9)).frame(width: 10, height: 5) }.offset(y: -6)
            HStack(spacing: 10) {
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.4).frame(width: 7)
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.4).frame(width: 7)
            }
            .offset(y: -5)
            Circle().trim(from: 0.1, to: 0.4).stroke(ink, lineWidth: 1.4).frame(width: 10).offset(y: 10)
            HStack(spacing: 26) { Ellipse().fill(blush).frame(width: 7, height: 4); Ellipse().fill(blush).frame(width: 7, height: 4) }.offset(y: 4)
        }
    }
}

private struct Serum: View {
    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color(red: 0.25, green: 0.25, blue: 0.28)).frame(width: 12, height: 14)
            Rectangle().fill(Color(red: 0.85, green: 0.80, blue: 0.70)).frame(width: 14, height: 5)
            RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.95, green: 0.78, blue: 0.70)).frame(width: 28, height: 42)
                .overlay(RoundedRectangle(cornerRadius: 2).fill(.white).frame(width: 18, height: 14).overlay(Text("glow").font(Theme.handwriting(size: 9)).foregroundStyle(ink)))
        }
    }
}

private struct SleepMask: View {
    var body: some View {
        ZStack {
            Capsule().fill(Color(red: 0.65, green: 0.55, blue: 0.85)).frame(width: 72, height: 6)
            HStack(spacing: -6) { ForEach(0..<2) { _ in Ellipse().fill(Color(red: 0.98, green: 0.80, blue: 0.86)).frame(width: 34, height: 26) } }
            HStack(spacing: 14) {
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.4).frame(width: 9)
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.4).frame(width: 9)
            }
        }
    }
}

private struct BathBomb: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.75, green: 0.85, blue: 0.98))
            Circle().trim(from: 0.5, to: 1).fill(Color(red: 0.98, green: 0.78, blue: 0.86))
            ForEach(Array([(-10.0, -8.0), (8.0, -12.0), (12.0, 6.0), (-8.0, 10.0), (0.0, 0.0)].enumerated()), id: \.offset) { _, p in
                Circle().fill(.white.opacity(0.8)).frame(width: 3).offset(x: p.0, y: p.1)
            }
            Image(systemName: "sparkle").font(.system(size: 10)).foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.40)).offset(x: 18, y: -18)
        }
    }
}
