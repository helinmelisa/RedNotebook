import SwiftUI

/// Bullet journal style stickers: ink doodles, header banners, labels, dividers and highlighter strokes.
struct BujoStickerView: View {
    let sticker: DrawnSticker

    private static let ink = Color(red: 0.18, green: 0.18, blue: 0.22)
    private static let doodleStroke = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)

    var body: some View {
        switch sticker {
        // Banners & labels
        case .bannerToday:
            Banner(text: "TODAY", color: Color(red: 0.96, green: 0.76, blue: 0.78))
        case .bannerNotes:
            Banner(text: "NOTES", color: Color(red: 0.72, green: 0.85, blue: 0.93))
        case .labelTodo:
            PaperLabel(text: "to do", color: Color(red: 0.80, green: 0.90, blue: 0.78))
        case .labelGoals:
            PaperLabel(text: "goals", color: Color(red: 1.0, green: 0.90, blue: 0.62))
        case .labelMemo:
            PaperLabel(text: "memo", color: Color(red: 0.88, green: 0.82, blue: 0.95))
        case .flagImportant:
            ImportantFlag()

        // Ink doodles
        case .arrowCurly:
            CurlyArrow().stroke(Self.ink, style: Self.doodleStroke).frame(width: 70, height: 40)
        case .checkbox:
            ZStack {
                RoundedRectangle(cornerRadius: 4).stroke(Self.ink, style: Self.doodleStroke).frame(width: 28, height: 28)
                Tick().stroke(Theme.coverRed, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .frame(width: 34, height: 30).offset(x: 4, y: -4)
            }
            .frame(width: 44, height: 44)
        case .starOutline:
            StarShape().stroke(Self.ink, style: Self.doodleStroke)
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(-6))
        case .heartOutline:
            inkSymbol("heart")
        case .circleDoodle:
            ZStack {
                Ellipse().stroke(Theme.coverRed, style: Self.doodleStroke)
                Ellipse().trim(from: 0, to: 0.35).stroke(Theme.coverRed, style: Self.doodleStroke)
                    .rotationEffect(.degrees(8)).scaleEffect(1.06)
            }
            .frame(width: 70, height: 44)
        case .sprig:
            Sprig().frame(width: 70, height: 40)
        case .speech:
            inkSymbol("bubble.left")
        case .lightbulb:
            inkSymbol("lightbulb")
                .background(Circle().fill(Color(red: 1.0, green: 0.88, blue: 0.40).opacity(0.5)).frame(width: 30, height: 30).offset(y: -4))
        case .moonStars:
            inkSymbol("moon.stars")
        case .coffee:
            inkSymbol("cup.and.saucer")
        case .envelope:
            inkSymbol("envelope")
        case .paperclip:
            inkSymbol("paperclip").rotationEffect(.degrees(30))
        case .pin:
            Image(systemName: "pin.fill")
                .font(.system(size: 30))
                .foregroundStyle(Theme.coverRed)
                .rotationEffect(.degrees(25))
                .shadow(color: .black.opacity(0.25), radius: 1.5, x: 2, y: 2)

        // Dividers & markers
        case .dividerWavy:
            Wave().stroke(Self.ink.opacity(0.8), style: Self.doodleStroke).frame(width: 110, height: 14)
        case .dividerDots:
            HStack(spacing: 7) {
                ForEach(0..<10, id: \.self) { _ in Circle().fill(Self.ink.opacity(0.7)).frame(width: 3.5, height: 3.5) }
            }
        case .dividerHeart:
            HStack(spacing: 8) {
                Rectangle().fill(Self.ink.opacity(0.7)).frame(width: 42, height: 1.5)
                Image(systemName: "heart.fill").font(.system(size: 11)).foregroundStyle(Theme.coverRed)
                Rectangle().fill(Self.ink.opacity(0.7)).frame(width: 42, height: 1.5)
            }
        case .highlighterYellow:
            Highlighter(color: Color(red: 1.0, green: 0.90, blue: 0.20))
        case .highlighterPink:
            Highlighter(color: Color(red: 1.0, green: 0.55, blue: 0.70))

        default:
            MoreStickerView(sticker: sticker)
        }
    }

    private func inkSymbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 36, weight: .light))
            .foregroundStyle(Self.ink)
    }
}

// MARK: - Banners & labels

/// Ribbon banner with folded tails, for page headers.
private struct Banner: View {
    let text: String
    let color: Color

    var body: some View {
        ZStack {
            HStack(spacing: 92) {
                BannerTail().fill(color.mix(with: .black, by: 0.15)).frame(width: 22, height: 24)
                BannerTail().fill(color.mix(with: .black, by: 0.15)).frame(width: 22, height: 24).scaleEffect(x: -1)
            }
            .offset(y: 7)
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .serif))
                .tracking(3)
                .foregroundStyle(Color(red: 0.25, green: 0.20, blue: 0.22))
                .frame(width: 110, height: 28)
                .background(Rectangle().fill(color))
                .overlay(Rectangle().stroke(.black.opacity(0.15), lineWidth: 0.5))
        }
        .frame(width: 150, height: 44)
        .shadow(color: .black.opacity(0.15), radius: 1.5, x: 0, y: 1.5)
    }
}

/// Banner tail with a V notch.
private struct BannerTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Paper label with a dashed stitch line and handwritten text.
private struct PaperLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(Theme.handwriting(size: 24))
            .foregroundStyle(Color(red: 0.22, green: 0.20, blue: 0.22))
            .frame(width: 96, height: 36)
            .background(RoundedRectangle(cornerRadius: 5).fill(color))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .inset(by: 3.5)
                    .stroke(.white.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [3, 2.5]))
            )
            .stickerOutline(1.5)
    }
}

private struct ImportantFlag: View {
    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(Color(red: 0.35, green: 0.30, blue: 0.28)).frame(width: 2.5, height: 46)
            Pennant()
                .fill(Theme.coverRed)
                .frame(width: 34, height: 26)
                .overlay(Text("!").font(.system(size: 15, weight: .black, design: .serif)).foregroundStyle(.white).offset(x: -5))
                .offset(y: -10)
        }
        .stickerOutline(1.5)
    }
}

private struct Pennant: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Doodles

private struct CurlyArrow: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path()
        // One relaxed swoosh, like a quick pen stroke
        path.move(to: CGPoint(x: w * 0.04, y: h * 0.80))
        path.addCurve(to: CGPoint(x: w * 0.94, y: h * 0.30),
                      control1: CGPoint(x: w * 0.30, y: h * 1.05), control2: CGPoint(x: w * 0.60, y: h * 0.25))
        // Arrowhead
        path.move(to: CGPoint(x: w * 0.78, y: h * 0.14))
        path.addLine(to: CGPoint(x: w * 0.94, y: h * 0.30))
        path.addLine(to: CGPoint(x: w * 0.80, y: h * 0.50))
        return path
    }
}

private struct Tick: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.midY + rect.height * 0.1))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.maxY - rect.height * 0.12))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: CGPoint(x: rect.midX + rect.width * 0.1, y: rect.midY - rect.height * 0.05))
        return path
    }
}

private struct Sprig: View {
    private let green = Color(red: 0.35, green: 0.55, blue: 0.38)

    var body: some View {
        Canvas { context, size in
            var stem = Path()
            stem.move(to: CGPoint(x: 4, y: size.height * 0.8))
            stem.addQuadCurve(to: CGPoint(x: size.width - 4, y: size.height * 0.35),
                              control: CGPoint(x: size.width * 0.5, y: size.height * 0.85))
            context.stroke(stem, with: .color(green), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

            // Leaves alternate above and below the stem
            for i in 0..<5 {
                let t = 0.15 + Double(i) * 0.17
                let x = 4 + (size.width - 8) * t
                let y = size.height * (0.8 - 0.45 * t * t) + (i.isMultiple(of: 2) ? -7 : 7)
                var leaf = context
                leaf.translateBy(x: x, y: y)
                leaf.rotate(by: .degrees(i.isMultiple(of: 2) ? -35 : 35))
                leaf.fill(Path(ellipseIn: CGRect(x: -7, y: -3.5, width: 14, height: 7)), with: .color(green.opacity(0.85)))
            }
        }
    }
}

// MARK: - Dividers & markers

private struct Wave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waves = 6.0
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        for x in stride(from: 0.0, through: rect.width, by: 1) {
            let y = rect.midY + sin(x / rect.width * waves * 2 * .pi) * rect.height * 0.35
            path.addLine(to: CGPoint(x: rect.minX + x, y: y))
        }
        return path
    }
}

/// A marker stroke with slightly uneven ends, see-through like real highlighter ink.
private struct Highlighter: View {
    let color: Color

    var body: some View {
        UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 8,
                               bottomTrailingRadius: 3, topTrailingRadius: 8)
            .fill(color.opacity(0.45))
            .frame(width: 110, height: 20)
            .rotationEffect(.degrees(-2))
            .blendMode(.multiply)
    }
}
