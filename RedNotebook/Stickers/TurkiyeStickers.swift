import SwiftUI

/// More from Türkiye: coffee, Cappadocia, İstanbul, kilim and künefe.
struct TurkiyeStickerView: View {
    let sticker: DrawnSticker

    var body: some View {
        switch sticker {
        case .turkishCoffee: TurkishCoffee().frame(width: 58, height: 52).stickerOutline()
        case .cezve: Cezve().frame(width: 66, height: 50).stickerOutline()
        case .balloon: Balloon().frame(width: 46, height: 70).stickerOutline()
        case .galataTower: GalataTower().frame(width: 34, height: 76).stickerOutline()
        case .tulipTR: Lale().frame(width: 36, height: 70).stickerOutline()
        case .seagull: Seagull().frame(width: 70, height: 30).stickerOutline()
        case .kilimTile: Kilim().frame(width: 58, height: 58).stickerOutline(1.5)
        case .kunefe: Kunefe().frame(width: 60, height: 44).stickerOutline()
        case .evilEyeHand: Hamsa().frame(width: 50, height: 62).stickerOutline()
        default: EmptyView()
        }
    }
}

private let nazarBlue = Color(red: 0.08, green: 0.25, blue: 0.62)
private let copper = Color(red: 0.78, green: 0.48, blue: 0.28)

/// Coffee in a small cup with a saucer, and a lokum on the side.
private struct TurkishCoffee: View {
    var body: some View {
        ZStack {
            Ellipse().fill(.white).overlay(Ellipse().stroke(nazarBlue, lineWidth: 2)).frame(width: 56, height: 14).offset(y: 18)
            UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12)
                .fill(.white).overlay(UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12).stroke(nazarBlue, lineWidth: 1.5))
                .frame(width: 30, height: 26).offset(y: 2)
            // Tulip pattern band
            HStack(spacing: 3) { ForEach(0..<4) { _ in Circle().fill(nazarBlue).frame(width: 3.5) } }.offset(y: -2)
            Ellipse().fill(Color(red: 0.30, green: 0.18, blue: 0.10)).frame(width: 28, height: 6).offset(y: -10)
            Ellipse().fill(Color(red: 0.70, green: 0.55, blue: 0.40)).frame(width: 14, height: 3).offset(x: -4, y: -10) // foam
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 1.0, green: 0.75, blue: 0.80)).frame(width: 9, height: 8).offset(x: 20, y: 12)
        }
    }
}

/// A copper cezve, long handle to the side.
private struct Cezve: View {
    var body: some View {
        ZStack {
            Capsule().fill(Color(red: 0.55, green: 0.38, blue: 0.22)).frame(width: 36, height: 5).rotationEffect(.degrees(-12)).offset(x: 18, y: -6)
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 26, y: 0))
                p.addLine(to: CGPoint(x: 23, y: 10))
                p.addQuadCurve(to: CGPoint(x: 28, y: 32), control: CGPoint(x: 32, y: 22))
                p.addLine(to: CGPoint(x: -2, y: 32))
                p.addQuadCurve(to: CGPoint(x: 3, y: 10), control: CGPoint(x: -6, y: 22))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [copper.mix(with: .white, by: 0.2), copper, copper.mix(with: .black, by: 0.2)],
                                 startPoint: .leading, endPoint: .trailing))
            .frame(width: 26, height: 32)
            .offset(x: -12, y: 4)
        }
    }
}

/// A Cappadocia hot-air balloon.
private struct Balloon: View {
    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                Circle().fill(Color(red: 0.95, green: 0.45, blue: 0.40))
                HStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Rectangle().fill([Color(red: 1.0, green: 0.82, blue: 0.35), .clear, Color(red: 0.40, green: 0.70, blue: 0.85), .clear, Color(red: 1.0, green: 0.82, blue: 0.35)][i])
                            .frame(width: 8.8)
                    }
                }
                .mask(Circle())
            }
            .frame(width: 44, height: 44)
            Path { p in
                p.move(to: CGPoint(x: 8, y: 0)); p.addLine(to: CGPoint(x: 15, y: 16))
                p.move(to: CGPoint(x: 30, y: 0)); p.addLine(to: CGPoint(x: 23, y: 16))
            }
            .stroke(Color(red: 0.45, green: 0.35, blue: 0.28), lineWidth: 1)
            .frame(width: 38, height: 16)
            .offset(y: 40)
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.62, green: 0.45, blue: 0.30)).frame(width: 12, height: 10).offset(y: 56)
        }
    }
}

private struct GalataTower: View {
    private let stone = Color(red: 0.90, green: 0.85, blue: 0.75)

    var body: some View {
        VStack(spacing: 0) {
            Triangle().fill(Color(red: 0.30, green: 0.36, blue: 0.48)).frame(width: 26, height: 20)
            Rectangle().fill(stone.mix(with: .black, by: 0.1)).frame(width: 30, height: 4)
            HStack(spacing: 3) { ForEach(0..<4) { _ in Capsule().fill(Color(red: 0.30, green: 0.36, blue: 0.48)).frame(width: 3, height: 7) } }
                .frame(width: 26, height: 10).background(stone)
            Rectangle().fill(stone).frame(width: 24, height: 40)
                .overlay(VStack(spacing: 9) { ForEach(0..<3) { _ in Capsule().fill(.black.opacity(0.25)).frame(width: 3, height: 5) } })
        }
    }

    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
            return p
        }
    }
}

/// The Ottoman tulip: slender, with pointed petals.
private struct Lale: View {
    var body: some View {
        ZStack(alignment: .top) {
            Capsule().fill(Color(red: 0.35, green: 0.60, blue: 0.35)).frame(width: 2.5, height: 44).offset(y: 24)
            Ellipse().fill(Color(red: 0.40, green: 0.66, blue: 0.40)).frame(width: 7, height: 26).rotationEffect(.degrees(-25)).offset(x: -6, y: 40)
            ZStack {
                ForEach([-1.0, 0.0, 1.0], id: \.self) { side in
                    Petal().fill(Color(red: 0.85, green: 0.15, blue: 0.22).mix(with: .white, by: side == 0 ? 0.15 : 0))
                        .frame(width: 11, height: 30)
                        .rotationEffect(.degrees(side * 16), anchor: .bottom)
                }
            }
            .frame(height: 30)
        }
    }

    private struct Petal: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX + rect.width * 0.5, y: rect.maxY * 0.7))
            p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX - rect.width * 0.5, y: rect.maxY * 0.7))
            return p
        }
    }
}

/// A Bosphorus seagull in a few strokes.
private struct Seagull: View {
    var body: some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: 0, y: 18))
                p.addQuadCurve(to: CGPoint(x: 35, y: 20), control: CGPoint(x: 16, y: 0))
                p.addQuadCurve(to: CGPoint(x: 70, y: 16), control: CGPoint(x: 54, y: 0))
            }
            .stroke(Color(red: 0.25, green: 0.28, blue: 0.32), style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
            Ellipse().fill(.white).overlay(Ellipse().stroke(Color(white: 0.7), lineWidth: 0.8)).frame(width: 16, height: 9).offset(y: 6)
            Circle().fill(Color(red: 1.0, green: 0.75, blue: 0.20)).frame(width: 4).offset(x: -9, y: 5)
        }
    }
}

/// A square of kilim weave: stepped diamonds in madder red, indigo and ochre.
private struct Kilim: View {
    var body: some View {
        Canvas { context, size in
            let red = Color(red: 0.70, green: 0.20, blue: 0.18), ochre = Color(red: 0.88, green: 0.66, blue: 0.30)
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(red))
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            for (i, color) in [Color(red: 0.98, green: 0.94, blue: 0.85), nazarBlue, ochre, Color(red: 0.98, green: 0.94, blue: 0.85)].enumerated() {
                let r = size.width * (0.42 - Double(i) * 0.1)
                var d = Path()
                d.move(to: CGPoint(x: c.x, y: c.y - r)); d.addLine(to: CGPoint(x: c.x + r, y: c.y))
                d.addLine(to: CGPoint(x: c.x, y: c.y + r)); d.addLine(to: CGPoint(x: c.x - r, y: c.y)); d.closeSubpath()
                context.fill(d, with: .color(color))
            }
            // Fringe-like border
            for x in stride(from: 2.0, to: size.width, by: 6) {
                context.fill(Path(CGRect(x: x, y: 0, width: 3, height: 4)), with: .color(ochre))
                context.fill(Path(CGRect(x: x, y: size.height - 4, width: 3, height: 4)), with: .color(ochre))
            }
        }
    }
}

/// Künefe in its round copper tray, with crushed pistachio on top.
private struct Kunefe: View {
    var body: some View {
        ZStack {
            Ellipse().fill(copper).frame(width: 60, height: 30).offset(y: 6)
            Ellipse().fill(Color(red: 0.92, green: 0.58, blue: 0.22)).frame(width: 52, height: 24).offset(y: 3)
            ForEach(Array([(-14.0, 1.0), (-4.0, -2.0), (8.0, 3.0), (16.0, -1.0), (0.0, 6.0), (-10.0, 7.0)].enumerated()), id: \.offset) { _, p in
                Circle().fill(Color(red: 0.45, green: 0.70, blue: 0.30)).frame(width: 3.5).offset(x: p.0, y: p.1)
            }
        }
    }
}

/// A hamsa hand with a nazar in its palm.
private struct Hamsa: View {
    var body: some View {
        ZStack {
            HStack(alignment: .bottom, spacing: 1) {
                ForEach([18.0, 24.0, 26.0, 24.0, 18.0], id: \.self) { h in
                    Capsule().fill(Color(red: 0.95, green: 0.85, blue: 0.55)).frame(width: 8.5, height: h)
                }
            }
            .offset(y: -16)
            UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 22, bottomTrailingRadius: 22, topTrailingRadius: 6)
                .fill(Color(red: 0.95, green: 0.85, blue: 0.55)).frame(width: 46, height: 36).offset(y: 10)
            Circle().fill(nazarBlue).frame(width: 22).offset(y: 10)
            Circle().fill(.white).frame(width: 13).offset(y: 10)
            Circle().fill(Color(red: 0.45, green: 0.75, blue: 0.95)).frame(width: 8).offset(y: 10)
            Circle().fill(Theme.ink).frame(width: 4).offset(y: 10)
        }
    }
}
