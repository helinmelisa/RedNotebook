import SwiftUI

/// Seasons & holidays, study & work, self-care, travel, and a few more from Portugal.
struct LifeStickerView: View {
    let sticker: DrawnSticker
    var text: String = ""

    var body: some View {
        switch sticker {
        // Seasons & holidays
        case .pumpkin: Pumpkin().frame(width: 58, height: 50).stickerOutline()
        case .ghost: Ghost().frame(width: 48, height: 56).stickerOutline()
        case .mapleLeaf:
            symbol("leaf.fill", Color(red: 0.92, green: 0.45, blue: 0.15)).rotationEffect(.degrees(-30))
        case .christmasTree: ChristmasTree().frame(width: 50, height: 62).stickerOutline()
        case .giftBox: palette("gift.fill", Color(red: 0.90, green: 0.25, blue: 0.30), Color(red: 1.0, green: 0.82, blue: 0.35))
        case .tulip: Tulip().frame(width: 40, height: 64).stickerOutline()
        case .sunflower: Sunflower().frame(width: 58, height: 58).stickerOutline()
        case .beachUmbrella: palette("beach.umbrella.fill", Color(red: 0.95, green: 0.45, blue: 0.40), Color(red: 0.85, green: 0.70, blue: 0.50))
        case .birthdayCake: palette("birthday.cake.fill", Color(red: 0.97, green: 0.62, blue: 0.72), Color(red: 1.0, green: 0.82, blue: 0.40))

        // Study & work
        case .bookStack: BookStack().stickerOutline()
        case .colourPencil: ColourPencil().frame(width: 84, height: 18).rotationEffect(.degrees(-20)).stickerOutline()
        case .gradCap: symbol("graduationcap.fill", Color(red: 0.20, green: 0.20, blue: 0.28))
        case .laptop: palette("laptopcomputer", Color(red: 0.55, green: 0.58, blue: 0.65), Color(red: 0.62, green: 0.80, blue: 0.95))
        case .alarmClock: palette("alarm.fill", Theme.red, Color(red: 0.98, green: 0.95, blue: 0.88))
        case .labelDeadline: TapeLabel(text: text.isEmpty ? "deadline!" : text, color: Theme.red, textColor: .white)
        case .labelExam: TapeLabel(text: text.isEmpty ? "exam" : text, color: Color(red: 1.0, green: 0.85, blue: 0.35), textColor: Theme.ink)

        // Self-care
        case .waterGlass: WaterGlass().frame(width: 38, height: 52).stickerOutline()
        case .sleepyMoon: palette("moon.zzz.fill", Color(red: 1.0, green: 0.82, blue: 0.35), Color(red: 0.45, green: 0.50, blue: 0.80))
        case .teaCup: palette("cup.and.heat.waves.fill", Color(red: 0.75, green: 0.55, blue: 0.85), Color(red: 0.70, green: 0.70, blue: 0.75))
        case .candle: Candle().frame(width: 30, height: 60).stickerOutline()
        case .pottedPlant: PottedPlant().frame(width: 50, height: 58).stickerOutline()
        case .bubbleBath: palette("bathtub.fill", Color(red: 0.55, green: 0.75, blue: 0.95), Color(red: 0.95, green: 0.95, blue: 1.0))

        // Travel
        case .plane: symbol("airplane", Color(red: 0.35, green: 0.60, blue: 0.90)).rotationEffect(.degrees(-25))
        case .suitcase: palette("suitcase.rolling.fill", Color(red: 0.95, green: 0.60, blue: 0.35), Color(red: 0.35, green: 0.30, blue: 0.30))
        case .mapPin: palette("mappin.and.ellipse", Theme.red, Theme.ink.opacity(0.35))
        case .camera: palette("camera.fill", Color(red: 0.30, green: 0.30, blue: 0.35), Color(red: 0.95, green: 0.70, blue: 0.75))
        case .globe: palette("globe.europe.africa.fill", Color(red: 0.45, green: 0.72, blue: 0.45), Color(red: 0.45, green: 0.68, blue: 0.95))

        // More Portugal
        case .andorinha: symbol("bird.fill", Color(red: 0.12, green: 0.15, blue: 0.30)).rotationEffect(.degrees(-12))
        case .portWine: palette("wineglass.fill", Color(red: 0.55, green: 0.08, blue: 0.18), Color(red: 0.85, green: 0.88, blue: 0.92))

        default: FunStickerView(sticker: sticker, text: text)
        }
    }

    private func symbol(_ name: String, _ color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 42))
            .foregroundStyle(color)
            .stickerOutline()
    }

    private func palette(_ name: String, _ primary: Color, _ secondary: Color) -> some View {
        Image(systemName: name)
            .symbolRenderingMode(.palette)
            .font(.system(size: 42))
            .foregroundStyle(primary, secondary)
            .stickerOutline()
    }
}

// MARK: - Seasons & holidays

private struct Pumpkin: View {
    private let orange = Color(red: 0.96, green: 0.55, blue: 0.15)

    var body: some View {
        ZStack {
            ForEach([-14.0, 14.0, 0.0], id: \.self) { x in
                Ellipse()
                    .fill(x == 0 ? orange : orange.mix(with: .black, by: 0.12))
                    .frame(width: x == 0 ? 28 : 30, height: 40)
                    .offset(x: x, y: 5)
            }
            Capsule().fill(Color(red: 0.40, green: 0.55, blue: 0.25)).frame(width: 6, height: 12).offset(y: -18)
            Image(systemName: "leaf.fill").font(.system(size: 10)).foregroundStyle(Color(red: 0.40, green: 0.65, blue: 0.30))
                .offset(x: 8, y: -20)
        }
    }
}

private struct Ghost: View {
    var body: some View {
        ZStack {
            GhostShape().fill(.white)
            GhostShape().stroke(Color(white: 0.85), lineWidth: 1)
            HStack(spacing: 10) {
                Ellipse().fill(Theme.ink).frame(width: 6, height: 9)
                Ellipse().fill(Theme.ink).frame(width: 6, height: 9)
            }
            .offset(y: -6)
            HStack(spacing: 18) {
                Circle().fill(Color(red: 1.0, green: 0.70, blue: 0.75)).frame(width: 7)
                Circle().fill(Color(red: 1.0, green: 0.70, blue: 0.75)).frame(width: 7)
            }
            .offset(y: 3)
        }
    }
}

/// Rounded top, wavy hem.
private struct GhostShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: w / 2))
        path.addArc(center: CGPoint(x: w / 2, y: w / 2), radius: w / 2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h))
        let waves = 3
        let step = w / CGFloat(waves)
        for i in 0..<waves {
            let x = w - CGFloat(i) * step
            path.addQuadCurve(to: CGPoint(x: x - step, y: h), control: CGPoint(x: x - step / 2, y: h - 9))
        }
        path.closeSubpath()
        return path
    }
}

private struct ChristmasTree: View {
    private let green = Color(red: 0.20, green: 0.55, blue: 0.35)

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(0..<3) { i in
                Triangle()
                    .fill(green.mix(with: .black, by: Double(i) * 0.06))
                    .frame(width: 30 + CGFloat(i) * 10, height: 24)
                    .offset(y: 8 + CGFloat(i) * 12)
            }
            Rectangle().fill(Color(red: 0.50, green: 0.32, blue: 0.20)).frame(width: 8, height: 8).offset(y: 54)
            Image(systemName: "star.fill").font(.system(size: 13)).foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.30))
            ForEach(Array([(-8.0, 24.0, Theme.red), (9.0, 34.0, Color(red: 1.0, green: 0.82, blue: 0.3)),
                           (-12.0, 44.0, Color(red: 0.45, green: 0.65, blue: 0.95)), (12.0, 46.0, Theme.red)].enumerated()),
                    id: \.offset) { _, ball in
                Circle().fill(ball.2).frame(width: 5).offset(x: ball.0, y: ball.1)
            }
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct Tulip: View {
    var body: some View {
        ZStack(alignment: .top) {
            Capsule().fill(Color(red: 0.35, green: 0.62, blue: 0.35)).frame(width: 3, height: 40).offset(y: 22)
            Ellipse().fill(Color(red: 0.45, green: 0.70, blue: 0.40)).frame(width: 10, height: 22)
                .rotationEffect(.degrees(35)).offset(x: 7, y: 36)
            ZStack {
                Ellipse().fill(Color(red: 0.95, green: 0.45, blue: 0.55)).frame(width: 16, height: 26).rotationEffect(.degrees(-18)).offset(x: -7)
                Ellipse().fill(Color(red: 0.95, green: 0.45, blue: 0.55)).frame(width: 16, height: 26).rotationEffect(.degrees(18)).offset(x: 7)
                Ellipse().fill(Color(red: 0.98, green: 0.58, blue: 0.66)).frame(width: 16, height: 28)
            }
            .frame(height: 28)
        }
    }
}

private struct Sunflower: View {
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Ellipse().fill(Color(red: 1.0, green: 0.80, blue: 0.20))
                    .frame(width: 11, height: 22)
                    .offset(y: -17)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            Circle().fill(Color(red: 0.45, green: 0.28, blue: 0.15)).frame(width: 24)
            Circle().stroke(Color(red: 0.30, green: 0.18, blue: 0.10), style: StrokeStyle(lineWidth: 1.5, dash: [1, 2.5])).frame(width: 16)
        }
    }
}

// MARK: - Study & work

private struct BookStack: View {
    var body: some View {
        VStack(spacing: 1) {
            book(Color(red: 0.55, green: 0.70, blue: 0.90), width: 56).offset(x: 4)
            book(Color(red: 0.95, green: 0.60, blue: 0.55), width: 64)
            book(Color(red: 0.60, green: 0.80, blue: 0.62), width: 60).offset(x: -3)
        }
    }

    private func book(_ color: Color, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: width, height: 13)
            .overlay(alignment: .trailing) {
                Rectangle().fill(Color(red: 0.98, green: 0.96, blue: 0.90)).frame(width: 5, height: 9).padding(.trailing, 2)
            }
            .overlay(alignment: .leading) {
                Rectangle().fill(.white.opacity(0.6)).frame(width: 14, height: 2).padding(.leading, 10)
            }
    }
}

private struct ColourPencil: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack(alignment: .leading) {
                Rectangle().fill(Color(red: 0.98, green: 0.80, blue: 0.30)).frame(width: w * 0.7, height: h).offset(x: w * 0.12)
                Rectangle().fill(Color(red: 0.95, green: 0.70, blue: 0.75)).frame(width: w * 0.12, height: h)
                Rectangle().fill(Color(white: 0.75)).frame(width: w * 0.05, height: h).offset(x: w * 0.1)
                Path { p in
                    p.move(to: CGPoint(x: w * 0.82, y: 0))
                    p.addLine(to: CGPoint(x: w, y: h / 2))
                    p.addLine(to: CGPoint(x: w * 0.82, y: h))
                }
                .fill(Color(red: 0.95, green: 0.85, blue: 0.70))
                Path { p in
                    p.move(to: CGPoint(x: w * 0.94, y: h * 0.33))
                    p.addLine(to: CGPoint(x: w, y: h / 2))
                    p.addLine(to: CGPoint(x: w * 0.94, y: h * 0.67))
                }
                .fill(Theme.ink)
            }
        }
    }
}

/// A strip of coloured tape with a word on it.
private struct TapeLabel: View {
    let text: String
    let color: Color
    let textColor: Color

    var body: some View {
        Text(text)
            .font(Theme.handwriting(size: 24).weight(.bold))
            .foregroundStyle(textColor)
            .fixedSize()
            .padding(.horizontal, 14)
            .padding(.vertical, 2)
            .background(Rectangle().fill(color.opacity(0.92)))
            .rotationEffect(.degrees(-3))
            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Self-care

private struct WaterGlass: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            GlassShape().fill(Color(red: 0.55, green: 0.80, blue: 0.98).opacity(0.85))
                .frame(height: 34)
                .mask(GlassShape())
            GlassShape().stroke(Color(red: 0.45, green: 0.62, blue: 0.80), lineWidth: 2)
            Circle().fill(.white.opacity(0.8)).frame(width: 4).offset(x: -6, y: -14)
            Circle().fill(.white.opacity(0.8)).frame(width: 3).offset(x: 5, y: -8)
        }
    }
}

/// A tumbler, a little wider at the top.
private struct GlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct Candle: View {
    var body: some View {
        VStack(spacing: 0) {
            Ellipse().fill(LinearGradient(colors: [Color(red: 1.0, green: 0.90, blue: 0.40), Color(red: 1.0, green: 0.55, blue: 0.20)],
                                          startPoint: .top, endPoint: .bottom))
                .frame(width: 10, height: 18)
            Rectangle().fill(Theme.ink).frame(width: 1.5, height: 4)
            RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.98, green: 0.88, blue: 0.85))
                .frame(width: 22, height: 34)
                .overlay(alignment: .top) {
                    Capsule().fill(Color(red: 0.98, green: 0.88, blue: 0.85)).frame(width: 6, height: 10).offset(x: 6, y: 2)
                }
        }
    }
}

private struct PottedPlant: View {
    private let green = Color(red: 0.35, green: 0.62, blue: 0.40)

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(Array([(-22.0, -10.0), (0.0, 0.0), (22.0, 10.0), (-40.0, -14.0), (40.0, 14.0)].enumerated()), id: \.offset) { _, leaf in
                Ellipse().fill(green.mix(with: .white, by: abs(leaf.0) > 40 ? 0.15 : 0))
                    .frame(width: 11, height: 26)
                    .offset(y: -24)
                    .rotationEffect(.degrees(leaf.0), anchor: .bottom)
                    .offset(y: -8)
            }
            GlassShape().fill(Color(red: 0.85, green: 0.48, blue: 0.32))
                .frame(width: 34, height: 24)
                .overlay(alignment: .top) {
                    Rectangle().fill(Color(red: 0.78, green: 0.42, blue: 0.28)).frame(width: 38, height: 6)
                }
        }
    }
}
