import SwiftUI

/// Food & café, animals, sky & dreamy, mood faces and a little Türkiye pack.
struct FunStickerView: View {
    let sticker: DrawnSticker

    var body: some View {
        switch sticker {
        // Food & café
        case .croissant: Croissant().frame(width: 68, height: 44).stickerOutline()
        case .boba: Boba().frame(width: 44, height: 64).stickerOutline()
        case .iceCream: IceCream().frame(width: 40, height: 66).stickerOutline()
        case .donut: Donut().frame(width: 54, height: 54).stickerOutline()
        case .avocado: Avocado().frame(width: 44, height: 58).stickerOutline()
        case .pizza: Pizza().frame(width: 52, height: 56).stickerOutline()
        case .lemon: Lemon().frame(width: 52, height: 52).stickerOutline()
        case .sushi: Sushi().frame(width: 50, height: 50).stickerOutline()

        // Animals
        case .bunny: Bunny().frame(width: 52, height: 64).stickerOutline()
        case .bear: Bear().frame(width: 56, height: 52).stickerOutline()
        case .frog: Frog().frame(width: 60, height: 48).stickerOutline()
        case .chick: Chick().frame(width: 50, height: 50).stickerOutline()
        case .bee: Bee().frame(width: 58, height: 46).stickerOutline()
        case .ladybug: Ladybug().frame(width: 48, height: 50).stickerOutline()

        // Sky & dreamy
        case .shootingStar: ShootingStar().frame(width: 76, height: 50).stickerOutline()
        case .saturn: Saturn().frame(width: 70, height: 50).stickerOutline()
        case .twinkle: Twinkle().frame(width: 56, height: 56).stickerOutline()
        case .cuteMoon: CuteMoon().frame(width: 54, height: 56).stickerOutline()
        case .rainCloud: RainCloud().frame(width: 60, height: 58).stickerOutline()

        // Mood faces
        case .faceHappy: Face(mood: .happy)
        case .faceLove: Face(mood: .love)
        case .faceSleepy: Face(mood: .sleepy)
        case .faceSad: Face(mood: .sad)
        case .faceAngry: Face(mood: .angry)
        case .faceExcited: Face(mood: .excited)

        // Türkiye
        case .nazar: Nazar().frame(width: 52, height: 52).stickerOutline()
        case .cay: Cay().frame(width: 46, height: 62).stickerOutline()
        case .simit: Simit().frame(width: 58, height: 58).stickerOutline()
        case .lokum: Lokum().stickerOutline()

        default: TravelStickerView(sticker: sticker)
        }
    }
}

private let blush = Color(red: 1.0, green: 0.65, blue: 0.70)

/// Two dot eyes and two blush cheeks: the face most of these animals share.
private struct CuteFace: View {
    var eyeGap: CGFloat = 14
    var blushGap: CGFloat = 26

    var body: some View {
        ZStack {
            HStack(spacing: eyeGap) {
                Circle().fill(Theme.ink).frame(width: 5)
                Circle().fill(Theme.ink).frame(width: 5)
            }
            HStack(spacing: blushGap) {
                Ellipse().fill(blush.opacity(0.8)).frame(width: 8, height: 5)
                Ellipse().fill(blush.opacity(0.8)).frame(width: 8, height: 5)
            }
            .offset(y: 6)
        }
    }
}

// MARK: - Food & café

private struct Croissant: View {
    private let crust = Color(red: 0.90, green: 0.62, blue: 0.28)

    var body: some View {
        ZStack {
            ForEach(-2...2, id: \.self) { i in
                let size = i == 0 ? CGSize(width: 24, height: 30) : CGSize(width: 20 - Double(abs(i)) * 3, height: 26 - Double(abs(i)) * 4)
                Ellipse()
                    .fill(crust.mix(with: .white, by: i == 0 ? 0.1 : 0))
                    .overlay(Ellipse().stroke(crust.mix(with: .black, by: 0.2), lineWidth: 1))
                    .frame(width: size.width, height: size.height)
                    .rotationEffect(.degrees(Double(i) * 28))
                    .offset(x: Double(i) * 12, y: Double(abs(i)) * 5)
                    .zIndex(Double(-abs(i)))
            }
        }
    }
}

private struct Boba: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 1.0, green: 0.62, blue: 0.72))
                .frame(width: 5, height: 26).rotationEffect(.degrees(12)).offset(x: 6, y: -6)
            Capsule().fill(Color(white: 0.95)).frame(width: 40, height: 9).offset(y: 10)
            CupShape().fill(Color(red: 0.86, green: 0.72, blue: 0.56))
                .frame(width: 36, height: 44).offset(y: 16)
            ForEach(Array([(-9.0, 50.0), (0.0, 52.0), (9.0, 50.0), (-5.0, 44.0), (5.0, 45.0)].enumerated()), id: \.offset) { _, pearl in
                Circle().fill(Color(red: 0.25, green: 0.16, blue: 0.12)).frame(width: 6).offset(x: pearl.0, y: pearl.1)
            }
        }
    }
}

/// Wider at the top, like a takeaway cup or a tumbler.
private struct CupShape: Shape {
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

private struct IceCream: View {
    var body: some View {
        ZStack(alignment: .top) {
            CupShape().fill(Color(red: 0.88, green: 0.68, blue: 0.40))
                .frame(width: 30, height: 40)
                .scaleEffect(x: 1, y: 1)
                .mask(DownTriangle().frame(width: 30, height: 40))
                .offset(y: 24)
            Circle().fill(Color(red: 1.0, green: 0.72, blue: 0.80)).frame(width: 36).offset(y: 4)
            Circle().fill(Theme.red).frame(width: 9).offset(x: 3, y: -2)
        }
    }
}

private struct DownTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// A ring: a circle with its middle cut out.
private struct Ring: Shape {
    var hole: CGFloat = 0.36

    func path(in rect: CGRect) -> Path {
        var path = Path(ellipseIn: rect)
        path.addEllipse(in: rect.insetBy(dx: rect.width * (0.5 - hole / 2), dy: rect.height * (0.5 - hole / 2)))
        return path.normalized(eoFill: true)
    }
}

private struct Donut: View {
    var body: some View {
        ZStack {
            Ring().fill(Color(red: 0.88, green: 0.66, blue: 0.40))
            Ring(hole: 0.42).fill(Color(red: 1.0, green: 0.62, blue: 0.75)).padding(4)
            ForEach(0..<10) { i in
                Capsule()
                    .fill([Color.yellow, .white, Color(red: 0.5, green: 0.75, blue: 1.0), Color(red: 0.55, green: 0.85, blue: 0.55)][i % 4])
                    .frame(width: 2.5, height: 7)
                    .rotationEffect(.degrees(Double(i) * 47))
                    .offset(y: -17)
                    .rotationEffect(.degrees(Double(i) * 36))
            }
        }
    }
}

private struct Avocado: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color(red: 0.25, green: 0.42, blue: 0.20))
            Ellipse().fill(Color(red: 0.78, green: 0.88, blue: 0.50)).padding(5)
            Circle().fill(Color(red: 0.58, green: 0.38, blue: 0.22)).frame(width: 20).offset(y: 8)
            CuteFace(eyeGap: 10, blushGap: 22).scaleEffect(0.8).offset(y: -8)
        }
    }
}

private struct Pizza: View {
    var body: some View {
        ZStack(alignment: .top) {
            DownTriangle().fill(Color(red: 1.0, green: 0.82, blue: 0.40)).frame(width: 50, height: 52).offset(y: 4)
            Capsule().fill(Color(red: 0.85, green: 0.58, blue: 0.30)).frame(width: 54, height: 10)
            ForEach(Array([(-10.0, 16.0), (8.0, 20.0), (-2.0, 32.0)].enumerated()), id: \.offset) { _, slice in
                Circle().fill(Color(red: 0.85, green: 0.25, blue: 0.20)).frame(width: 9).offset(x: slice.0, y: slice.1)
            }
        }
    }
}

private struct Lemon: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 1.0, green: 0.85, blue: 0.20))
            Circle().fill(Color(red: 1.0, green: 0.96, blue: 0.70)).padding(4)
            ForEach(0..<8) { i in
                Ellipse().fill(Color(red: 1.0, green: 0.88, blue: 0.35))
                    .frame(width: 9, height: 17)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
    }
}

private struct Sushi: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.15, green: 0.22, blue: 0.18))
            Circle().fill(.white).padding(5)
            Circle().fill(Color(red: 1.0, green: 0.55, blue: 0.40)).frame(width: 18)
            Circle().fill(Color(red: 0.55, green: 0.80, blue: 0.45)).frame(width: 6).offset(x: 4, y: 3)
        }
    }
}

// MARK: - Animals

private struct Bunny: View {
    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Capsule().fill(.white).frame(width: 14, height: 34)
                    .overlay(Capsule().fill(blush.opacity(0.7)).frame(width: 6, height: 22))
                    .rotationEffect(.degrees(side * 10))
                    .offset(x: side * 10, y: -18)
            }
            Ellipse().fill(.white).frame(width: 50, height: 42).offset(y: 10)
            CuteFace().offset(y: 8)
            Ellipse().fill(blush).frame(width: 5, height: 4).offset(y: 13)
        }
    }
}

private struct Bear: View {
    private let fur = Color(red: 0.70, green: 0.50, blue: 0.35)

    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Circle().fill(fur).frame(width: 18).offset(x: side * 18, y: -16)
                Circle().fill(fur.mix(with: .white, by: 0.3)).frame(width: 9).offset(x: side * 18, y: -16)
            }
            Circle().fill(fur).frame(width: 48).offset(y: 3)
            Ellipse().fill(fur.mix(with: .white, by: 0.4)).frame(width: 20, height: 14).offset(y: 11)
            CuteFace(eyeGap: 16, blushGap: 30).offset(y: 0)
            Ellipse().fill(Theme.ink).frame(width: 7, height: 5).offset(y: 8)
        }
    }
}

private struct Frog: View {
    private let green = Color(red: 0.50, green: 0.78, blue: 0.45)

    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Circle().fill(green).frame(width: 20).offset(x: side * 15, y: -14)
                Circle().fill(.white).frame(width: 12).offset(x: side * 15, y: -14)
                Circle().fill(Theme.ink).frame(width: 6).offset(x: side * 15, y: -14)
            }
            Ellipse().fill(green).frame(width: 58, height: 36).offset(y: 6)
            Circle().trim(from: 0.1, to: 0.4).stroke(Theme.ink, lineWidth: 1.5).frame(width: 18).offset(y: 2)
            HStack(spacing: 30) {
                Ellipse().fill(blush.opacity(0.8)).frame(width: 8, height: 5)
                Ellipse().fill(blush.opacity(0.8)).frame(width: 8, height: 5)
            }
            .offset(y: 8)
        }
    }
}

private struct Chick: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 1.0, green: 0.88, blue: 0.35))
            Image(systemName: "leaf.fill").font(.system(size: 9)).foregroundStyle(Color(red: 1.0, green: 0.80, blue: 0.25))
                .rotationEffect(.degrees(-60)).offset(y: -26)
            CuteFace().offset(y: -2)
            DownTriangle().fill(Color(red: 1.0, green: 0.58, blue: 0.20)).frame(width: 9, height: 7).offset(y: 5)
        }
    }
}

private struct Bee: View {
    var body: some View {
        ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Ellipse().fill(.white.opacity(0.9)).overlay(Ellipse().stroke(Color(white: 0.8), lineWidth: 1))
                    .frame(width: 18, height: 24).rotationEffect(.degrees(side * 25)).offset(x: side * 8, y: -14)
            }
            Ellipse().fill(Color(red: 1.0, green: 0.82, blue: 0.25)).frame(width: 46, height: 32)
            ForEach([-6.0, 6.0], id: \.self) { x in
                Rectangle().fill(Theme.ink).frame(width: 5, height: 30).offset(x: x)
            }
            .mask(Ellipse().frame(width: 46, height: 32))
            Circle().fill(Theme.ink).frame(width: 4).offset(x: -16, y: -3)
        }
    }
}

private struct Ladybug: View {
    var body: some View {
        ZStack {
            Circle().fill(Theme.ink).frame(width: 22).offset(y: -16)
            Circle().fill(Color(red: 0.90, green: 0.18, blue: 0.20)).frame(width: 46).offset(y: 3)
            Rectangle().fill(Theme.ink).frame(width: 1.5, height: 44).offset(y: 3)
            ForEach(Array([(-11.0, -4.0), (11.0, -4.0), (-12.0, 12.0), (12.0, 12.0), (-4.0, 20.0), (4.0, 20.0)].enumerated()), id: \.offset) { _, spot in
                Circle().fill(Theme.ink).frame(width: 7).offset(x: spot.0, y: spot.1)
            }
        }
    }
}

// MARK: - Sky & dreamy

private struct ShootingStar: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ForEach(Array([Color(red: 1.0, green: 0.70, blue: 0.80), Color(red: 0.70, green: 0.80, blue: 1.0),
                           Color(red: 1.0, green: 0.88, blue: 0.50)].enumerated()), id: \.offset) { i, color in
                Capsule().fill(color).frame(width: 46, height: 5)
                    .rotationEffect(.degrees(-28))
                    .offset(x: -22, y: 22 + CGFloat(i) * 6)
            }
            StarShape().fill(Color(red: 1.0, green: 0.84, blue: 0.30)).frame(width: 34, height: 34)
        }
    }
}

private struct Saturn: View {
    var body: some View {
        ZStack {
            Ellipse().stroke(Color(red: 0.95, green: 0.75, blue: 0.55), lineWidth: 4).frame(width: 66, height: 20).rotationEffect(.degrees(-18))
            Circle().fill(Color(red: 0.98, green: 0.78, blue: 0.62)).frame(width: 34)
            Ellipse().trim(from: 0, to: 0.5).stroke(Color(red: 0.95, green: 0.75, blue: 0.55), lineWidth: 4)
                .frame(width: 66, height: 20).rotationEffect(.degrees(-18))
        }
    }
}

/// A four-pointed sparkle.
private struct Sparkle: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: CGPoint(x: c.x, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: c.y), control: c)
        path.addQuadCurve(to: CGPoint(x: c.x, y: rect.maxY), control: c)
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: c.y), control: c)
        path.addQuadCurve(to: CGPoint(x: c.x, y: rect.minY), control: c)
        return path
    }
}

private struct Twinkle: View {
    var body: some View {
        ZStack {
            Sparkle().fill(Color(red: 1.0, green: 0.84, blue: 0.35)).frame(width: 42, height: 42)
            Sparkle().fill(Color(red: 0.75, green: 0.70, blue: 1.0)).frame(width: 14, height: 14).offset(x: 20, y: -18)
            Sparkle().fill(Color(red: 1.0, green: 0.70, blue: 0.80)).frame(width: 11, height: 11).offset(x: -20, y: 18)
        }
    }
}

private struct CuteMoon: View {
    var body: some View {
        ZStack {
            Crescent().fill(Color(red: 1.0, green: 0.86, blue: 0.40))
            // Sleeping face on the crescent
            HStack(spacing: 2) {
                Circle().trim(from: 0, to: 0.5).stroke(Theme.ink, lineWidth: 1.5).frame(width: 7)
            }
            .offset(x: -10, y: -2)
            Ellipse().fill(blush.opacity(0.8)).frame(width: 7, height: 4).offset(x: -12, y: 6)
        }
    }
}

private struct Crescent: Shape {
    func path(in rect: CGRect) -> Path {
        // A full moon with a second, offset circle bitten out of it
        Path(ellipseIn: rect).subtracting(Path(ellipseIn: rect.offsetBy(dx: rect.width * 0.35, dy: -rect.height * 0.1)))
    }
}

private struct RainCloud: View {
    var body: some View {
        ZStack(alignment: .top) {
            Image(systemName: "cloud.fill").font(.system(size: 46)).foregroundStyle(Color(red: 0.78, green: 0.85, blue: 0.95))
            HStack(spacing: 9) {
                ForEach(0..<3) { i in
                    Image(systemName: "drop.fill").font(.system(size: 10))
                        .foregroundStyle(Color(red: 0.45, green: 0.65, blue: 0.95))
                        .offset(y: CGFloat(i % 2) * 6)
                }
            }
            .offset(y: 38)
        }
    }
}

// MARK: - Mood faces

private struct Face: View {
    enum Mood { case happy, love, sleepy, sad, angry, excited }
    let mood: Mood

    var body: some View {
        ZStack {
            Circle().fill(color)
            features
        }
        .frame(width: 50, height: 50)
        .stickerOutline()
    }

    private var color: Color {
        switch mood {
        case .angry: Color(red: 1.0, green: 0.62, blue: 0.55)
        case .sad: Color(red: 0.72, green: 0.82, blue: 0.98)
        case .sleepy: Color(red: 0.85, green: 0.80, blue: 0.98)
        case .love: Color(red: 1.0, green: 0.80, blue: 0.85)
        default: Color(red: 1.0, green: 0.88, blue: 0.45)
        }
    }

    @ViewBuilder
    private var features: some View {
        let ink = Theme.ink
        switch mood {
        case .happy:
            CuteFace()
            Circle().trim(from: 0.1, to: 0.4).stroke(ink, style: StrokeStyle(lineWidth: 2, lineCap: .round)).frame(width: 14).offset(y: 4)
        case .love:
            HStack(spacing: 10) {
                Image(systemName: "heart.fill"); Image(systemName: "heart.fill")
            }
            .font(.system(size: 10)).foregroundStyle(Theme.red).offset(y: -4)
            Circle().trim(from: 0.1, to: 0.4).stroke(ink, style: StrokeStyle(lineWidth: 2, lineCap: .round)).frame(width: 14).offset(y: 4)
        case .sleepy:
            HStack(spacing: 10) {
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.8).frame(width: 8)
                Circle().trim(from: 0, to: 0.5).stroke(ink, lineWidth: 1.8).frame(width: 8)
            }
            .offset(y: -4)
            Ellipse().stroke(ink, lineWidth: 1.5).frame(width: 6, height: 7).offset(y: 10)
            Text("z").font(Theme.handwriting(size: 16).weight(.bold)).foregroundStyle(Color(red: 0.45, green: 0.40, blue: 0.75)).offset(x: 16, y: -16)
        case .sad:
            CuteFace()
            Circle().trim(from: 0.6, to: 0.9).stroke(ink, style: StrokeStyle(lineWidth: 2, lineCap: .round)).frame(width: 14).offset(y: 14)
            Image(systemName: "drop.fill").font(.system(size: 7)).foregroundStyle(Color(red: 0.35, green: 0.55, blue: 0.95)).offset(x: -9, y: 5)
        case .angry:
            HStack(spacing: 10) {
                Rectangle().fill(ink).frame(width: 9, height: 2).rotationEffect(.degrees(20))
                Rectangle().fill(ink).frame(width: 9, height: 2).rotationEffect(.degrees(-20))
            }
            .offset(y: -9)
            CuteFace()
            Circle().trim(from: 0.6, to: 0.9).stroke(ink, style: StrokeStyle(lineWidth: 2, lineCap: .round)).frame(width: 14).offset(y: 14)
        case .excited:
            HStack(spacing: 10) {
                Sparkle().fill(ink).frame(width: 9, height: 9)
                Sparkle().fill(ink).frame(width: 9, height: 9)
            }
            .offset(y: -4)
            UnevenRoundedRectangle(bottomLeadingRadius: 8, bottomTrailingRadius: 8)
                .fill(ink).frame(width: 16, height: 9).offset(y: 9)
            Capsule().fill(blush).frame(width: 8, height: 4).offset(y: 11)
        }
    }
}

// MARK: - Türkiye

/// Nazar boncuğu: the blue evil-eye bead.
private struct Nazar: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.08, green: 0.25, blue: 0.62))
            Circle().fill(.white).padding(9)
            Circle().fill(Color(red: 0.45, green: 0.75, blue: 0.95)).padding(15)
            Circle().fill(Theme.ink).padding(20)
            Circle().fill(.white.opacity(0.7)).frame(width: 6).offset(x: -12, y: -12)
        }
    }
}

/// Tea in a tulip-shaped glass on a little red saucer.
private struct Cay: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse().fill(Color(red: 0.80, green: 0.15, blue: 0.18)).frame(width: 44, height: 10)
            TulipGlass()
                .fill(LinearGradient(colors: [Color(red: 0.85, green: 0.35, blue: 0.12), Color(red: 0.62, green: 0.18, blue: 0.06)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(TulipGlass().stroke(.white.opacity(0.85), lineWidth: 1.5))
                .frame(width: 30, height: 50)
                .offset(y: -5)
            Capsule().fill(.white.opacity(0.5)).frame(width: 3, height: 18).offset(x: -7, y: -26)
        }
    }
}

/// The waisted "ince belli" glass: wide at the rim, narrow in the middle, round at the bottom.
private struct TulipGlass: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addQuadCurve(to: CGPoint(x: w * 0.72, y: h * 0.45), control: CGPoint(x: w * 0.9, y: h * 0.3))
        path.addQuadCurve(to: CGPoint(x: w * 0.62, y: h), control: CGPoint(x: w * 1.0, y: h * 0.8))
        path.addLine(to: CGPoint(x: w * 0.38, y: h))
        path.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.45), control: CGPoint(x: 0, y: h * 0.8))
        path.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: w * 0.1, y: h * 0.3))
        return path
    }
}

private struct Simit: View {
    var body: some View {
        ZStack {
            Ring(hole: 0.42).fill(Color(red: 0.78, green: 0.48, blue: 0.22))
            Ring(hole: 0.5).stroke(Color(red: 0.62, green: 0.35, blue: 0.15), lineWidth: 1).padding(6)
            ForEach(0..<22) { i in
                Ellipse().fill(Color(red: 0.98, green: 0.92, blue: 0.75))
                    .frame(width: 2.5, height: 4)
                    .rotationEffect(.degrees(Double(i * 37)))
                    .offset(y: i.isMultiple(of: 2) ? -20 : -14)
                    .rotationEffect(.degrees(Double(i) * 16.4))
            }
        }
    }
}

private struct Lokum: View {
    var body: some View {
        ZStack {
            ForEach(Array([(-14.0, 6.0, Color(red: 1.0, green: 0.72, blue: 0.80)), (14.0, 6.0, Color(red: 0.98, green: 0.62, blue: 0.72)),
                           (0.0, -8.0, Color(red: 1.0, green: 0.80, blue: 0.86))].enumerated()), id: \.offset) { _, cube in
                RoundedRectangle(cornerRadius: 5).fill(cube.2)
                    .frame(width: 24, height: 22)
                    .overlay(
                        // Powdered sugar
                        Canvas { context, size in
                            var rng = SeededRandom(seed: UInt64(cube.0 + 100))
                            for _ in 0..<14 {
                                let x = Double.random(in: 2...(size.width - 2), using: &rng)
                                let y = Double.random(in: 2...(size.height - 2), using: &rng)
                                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.8, height: 1.8)), with: .color(.white.opacity(0.9)))
                            }
                        }
                    )
                    .offset(x: cube.0, y: cube.1)
            }
        }
        .frame(width: 56, height: 46)
    }
}
