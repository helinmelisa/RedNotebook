import SwiftUI

/// Stickers drawn in code, so they stay crisp at any size.
///
/// Raw values are stored in the database, so existing cases must never be renamed.
enum DrawnSticker: String, CaseIterable, Identifiable {
    // Tape & cute
    case washiPink, washiMint, washiDots, star, heart, flower, sparkles, sun, cloud, tag
    // Banners & labels
    case bannerToday, bannerNotes, labelTodo, labelGoals, labelMemo, flagImportant
    // Ink doodles
    case arrowCurly, checkbox, starOutline, heartOutline, circleDoodle, sprig,
         speech, lightbulb, moonStars, coffee, envelope, paperclip, pin
    // Dividers & markers
    case dividerWavy, dividerDots, dividerHeart, highlighterYellow, highlighterPink
    // Portugal
    case azulejo, sardine, pastelDeNata, tram, stampPortugal, stampPorto, vianaHeart
    // Paper & scraps
    case polaroid, ticket, tornNote, indexFlags, gridNote
    // Words
    case wordYay, wordLove, wordOmg, wordThankYou, wordGoodDay, wordButFirstCoffee
    // More cute
    case strawberry, cherries, mushroom, rainbow, catFace, bow
    // Weekdays
    case weekdayMon, weekdayTue, weekdayWed, weekdayThu, weekdayFri, weekdaySat, weekdaySun
    // Seasons & holidays
    case pumpkin, ghost, mapleLeaf, christmasTree, giftBox, tulip, sunflower, beachUmbrella, birthdayCake
    // Study & work
    case bookStack, colourPencil, gradCap, laptop, alarmClock, labelDeadline, labelExam
    // Self-care
    case waterGlass, sleepyMoon, teaCup, candle, pottedPlant, bubbleBath
    // Travel
    case plane, suitcase, mapPin, camera, globe
    // More Portugal
    case andorinha, portWine, stampLisboa

    var id: Self { self }

    /// Sections of the sticker drawer, in the order they're shown.
    enum Category: String, CaseIterable {
        case cute = "Tape & cute"
        case words = "Words"
        case portugal = "Portugal 🇵🇹"
        case seasons = "Seasons & holidays"
        case study = "Study & work"
        case selfCare = "Self-care"
        case travel = "Travel"
        case labels = "Banners & labels"
        case doodles = "Ink doodles"
        case dividers = "Dividers & markers"
        case paper = "Paper & scraps"
        case weekdays = "Weekdays"
    }

    var category: Category {
        switch self {
        case .washiPink, .washiMint, .washiDots, .star, .heart, .flower, .sparkles, .sun, .cloud, .tag:
            .cute
        case .bannerToday, .bannerNotes, .labelTodo, .labelGoals, .labelMemo, .flagImportant:
            .labels
        case .arrowCurly, .checkbox, .starOutline, .heartOutline, .circleDoodle, .sprig,
             .speech, .lightbulb, .moonStars, .coffee, .envelope, .paperclip, .pin:
            .doodles
        case .dividerWavy, .dividerDots, .dividerHeart, .highlighterYellow, .highlighterPink:
            .dividers
        case .azulejo, .sardine, .pastelDeNata, .tram, .stampPortugal, .stampPorto, .vianaHeart:
            .portugal
        case .polaroid, .ticket, .tornNote, .indexFlags, .gridNote:
            .paper
        case .wordYay, .wordLove, .wordOmg, .wordThankYou, .wordGoodDay, .wordButFirstCoffee:
            .words
        case .strawberry, .cherries, .mushroom, .rainbow, .catFace, .bow:
            .cute
        case .weekdayMon, .weekdayTue, .weekdayWed, .weekdayThu, .weekdayFri, .weekdaySat, .weekdaySun:
            .weekdays
        case .pumpkin, .ghost, .mapleLeaf, .christmasTree, .giftBox, .tulip, .sunflower, .beachUmbrella, .birthdayCake:
            .seasons
        case .bookStack, .colourPencil, .gradCap, .laptop, .alarmClock, .labelDeadline, .labelExam:
            .study
        case .waterGlass, .sleepyMoon, .teaCup, .candle, .pottedPlant, .bubbleBath:
            .selfCare
        case .plane, .suitcase, .mapPin, .camera, .globe:
            .travel
        case .andorinha, .portWine, .stampLisboa:
            .portugal
        }
    }

    var name: String {
        switch self {
        case .washiPink: "Pink washi tape"
        case .washiMint: "Mint washi tape"
        case .washiDots: "Dotted washi tape"
        case .star: "Star"
        case .heart: "Heart"
        case .flower: "Flower"
        case .sparkles: "Sparkles"
        case .sun: "Sun"
        case .cloud: "Cloud"
        case .tag: "Tag"
        case .bannerToday: "Today banner"
        case .bannerNotes: "Notes banner"
        case .labelTodo: "To do label"
        case .labelGoals: "Goals label"
        case .labelMemo: "Memo label"
        case .flagImportant: "Important flag"
        case .arrowCurly: "Curly arrow"
        case .checkbox: "Ticked box"
        case .starOutline: "Doodle star"
        case .heartOutline: "Doodle heart"
        case .circleDoodle: "Hand-drawn circle"
        case .sprig: "Leaf sprig"
        case .speech: "Speech bubble"
        case .lightbulb: "Idea bulb"
        case .moonStars: "Moon and stars"
        case .coffee: "Coffee cup"
        case .envelope: "Envelope"
        case .paperclip: "Paperclip"
        case .pin: "Pin"
        case .dividerWavy: "Wavy divider"
        case .dividerDots: "Dotted divider"
        case .dividerHeart: "Heart divider"
        case .highlighterYellow: "Yellow highlighter"
        case .highlighterPink: "Pink highlighter"
        case .azulejo: "Azulejo tile"
        case .sardine: "Sardine"
        case .pastelDeNata: "Pastel de nata"
        case .tram: "Tram"
        case .stampPortugal: "Portugal stamp"
        case .stampPorto: "Porto stamp"
        case .vianaHeart: "Viana heart"
        case .polaroid: "Polaroid"
        case .ticket: "Ticket"
        case .tornNote: "Torn note"
        case .indexFlags: "Index flags"
        case .gridNote: "Grid note"
        case .wordYay: "Yay!"
        case .wordLove: "Love"
        case .wordOmg: "OMG"
        case .wordThankYou: "Thank you"
        case .wordGoodDay: "Good day"
        case .wordButFirstCoffee: "But first, coffee"
        case .strawberry: "Strawberry"
        case .cherries: "Cherries"
        case .mushroom: "Mushroom"
        case .rainbow: "Rainbow"
        case .catFace: "Cat"
        case .bow: "Bow"
        case .weekdayMon: "Monday"
        case .weekdayTue: "Tuesday"
        case .weekdayWed: "Wednesday"
        case .weekdayThu: "Thursday"
        case .weekdayFri: "Friday"
        case .weekdaySat: "Saturday"
        case .weekdaySun: "Sunday"
        case .pumpkin: "Pumpkin"
        case .ghost: "Ghost"
        case .mapleLeaf: "Autumn leaf"
        case .christmasTree: "Christmas tree"
        case .giftBox: "Gift"
        case .tulip: "Tulip"
        case .sunflower: "Sunflower"
        case .beachUmbrella: "Beach umbrella"
        case .birthdayCake: "Birthday cake"
        case .bookStack: "Books"
        case .colourPencil: "Pencil"
        case .gradCap: "Graduation cap"
        case .laptop: "Laptop"
        case .alarmClock: "Alarm clock"
        case .labelDeadline: "Deadline label"
        case .labelExam: "Exam label"
        case .waterGlass: "Glass of water"
        case .sleepyMoon: "Sleepy moon"
        case .teaCup: "Tea"
        case .candle: "Candle"
        case .pottedPlant: "Plant"
        case .bubbleBath: "Bubble bath"
        case .plane: "Plane"
        case .suitcase: "Suitcase"
        case .mapPin: "Map pin"
        case .camera: "Camera"
        case .globe: "Globe"
        case .andorinha: "Swallow"
        case .portWine: "Port wine"
        case .stampLisboa: "Lisboa stamp"
        }
    }
}

struct DrawnStickerView: View {
    let sticker: DrawnSticker

    var body: some View {
        switch sticker {
        case .washiPink:
            WashiTape(color: Color(red: 0.96, green: 0.70, blue: 0.75), pattern: .stripes)
        case .washiMint:
            WashiTape(color: Color(red: 0.62, green: 0.85, blue: 0.76), pattern: .grid)
        case .washiDots:
            WashiTape(color: Color(red: 0.98, green: 0.85, blue: 0.55), pattern: .dots)
        case .star:
            StarShape()
                .fill(Color(red: 1.0, green: 0.82, blue: 0.30))
                .overlay(StarShape().stroke(Color(red: 0.85, green: 0.60, blue: 0.10), lineWidth: 1.5))
                .frame(width: 54, height: 54)
                .stickerOutline()
        case .heart:
            symbol("heart.fill", Color(red: 0.90, green: 0.25, blue: 0.35))
        case .flower:
            Flower().frame(width: 56, height: 56).stickerOutline()
        case .sparkles:
            symbol("sparkles", Color(red: 1.0, green: 0.78, blue: 0.25))
        case .sun:
            symbol("sun.max.fill", Color(red: 1.0, green: 0.62, blue: 0.20))
        case .cloud:
            symbol("cloud.fill", Color(red: 0.62, green: 0.78, blue: 0.95))
        case .tag:
            Tag()
        default:
            BujoStickerView(sticker: sticker)
        }
    }

    private func symbol(_ name: String, _ color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 44))
            .foregroundStyle(color)
            .stickerOutline()
    }
}

extension View {
    /// White die-cut border and a soft shadow, like a real sticker.
    func stickerOutline(_ width: CGFloat = 2) -> some View {
        self
            .shadow(color: .white, radius: 0, x: width, y: 0)
            .shadow(color: .white, radius: 0, x: -width, y: 0)
            .shadow(color: .white, radius: 0, x: 0, y: width)
            .shadow(color: .white, radius: 0, x: 0, y: -width)
            .shadow(color: .black.opacity(0.22), radius: 2, x: 1, y: 2)
    }
}

// MARK: - Shapes

private struct WashiTape: View {
    enum Pattern { case stripes, grid, dots }
    let color: Color
    let pattern: Pattern

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
            }
        }
        .frame(width: 120, height: 30)
        .opacity(0.85) // tape is a little see-through
        .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
    }
}

/// Rectangle with torn zigzag edges on the left and right.
private struct ZigzagEnds: Shape {
    func path(in rect: CGRect) -> Path {
        let teeth = 5
        let depth: CGFloat = 4
        let step = rect.height / CGFloat(teeth)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        for i in 0..<teeth {
            let y = rect.minY + CGFloat(i) * step
            path.addLine(to: CGPoint(x: rect.maxX - depth, y: y + step / 2))
            path.addLine(to: CGPoint(x: rect.maxX, y: y + step))
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        for i in (0..<teeth).reversed() {
            let y = rect.minY + CGFloat(i) * step
            path.addLine(to: CGPoint(x: rect.minX + depth, y: y + step / 2))
            path.addLine(to: CGPoint(x: rect.minX, y: y))
        }
        path.closeSubpath()
        return path
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.45
        var path = Path()
        for i in 0..<10 {
            let radius = i.isMultiple(of: 2) ? outer : inner
            let angle = Double(i) * .pi / 5 - .pi / 2
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

private struct Flower: View {
    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                Ellipse()
                    .fill(Color(red: 0.98, green: 0.72, blue: 0.80))
                    .frame(width: 22, height: 30)
                    .offset(y: -14)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            Circle()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.35))
                .frame(width: 18, height: 18)
        }
    }
}

private struct Tag: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.93, green: 0.86, blue: 0.72))
            HStack(spacing: 6) {
                Circle().stroke(Color(red: 0.55, green: 0.45, blue: 0.35), lineWidth: 1.2).frame(width: 7, height: 7)
                Text("♡ today")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundStyle(Color(red: 0.40, green: 0.30, blue: 0.22))
            }
        }
        .frame(width: 92, height: 32)
        .stickerOutline(1.5)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 30) {
        ForEach(DrawnSticker.allCases) { DrawnStickerView(sticker: $0) }
    }
    .padding()
    .background(GridPaper())
}
