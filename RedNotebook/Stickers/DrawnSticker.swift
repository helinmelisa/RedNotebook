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
    // Food & café
    case croissant, boba, iceCream, donut, avocado, pizza, lemon, sushi
    // Animals
    case bunny, bear, frog, chick, bee, ladybug
    // Sky & dreamy
    case shootingStar, saturn, twinkle, cuteMoon, rainCloud
    // Mood faces
    case faceHappy, faceLove, faceSleepy, faceSad, faceAngry, faceExcited
    // Türkiye
    case nazar, cay, simit, lokum
    // Antalya
    case portakal, palmTree, caretta, hadrianGate, yivliMinare, gulet, nar, stampAntalya
    // More seasons
    case chestnuts, rainBoots, snowman, mitten, hotChocolate, sakura, watermelon, seashell, icePop, scarf
    // More food
    case onigiri, dango, matchaLatte, ramen, baklava, pancakes, cookie, cakeSlice
    // Vintage ephemera
    case waxSealRose, waxSealSprig, envelopeHeart, stampLavender, stampFern, newspaperScrap, musicSheet, kraftPaper,
         butterflyNight, butterflyCream, driedLavender, daisy, typewriter, satinBow, plasterTape, quoteStrip, pressedFlower,
         typedWords
    // More Türkiye
    case turkishCoffee, cezve, balloon, galataTower, tulipTR, seagull, kilimTile, stampIstanbul, kunefe, evilEyeHand
    // Batch: more Türkiye, vintage, animals, seasons, work, self-care and words in Portuguese & Turkish
    case vapur, fairyChimney, ayran, mosque, streetCat, lahmacun, vintageKey, pocketWatch, quillInk, floralTeacup, vintageCamera, cassette, sleepyCat, puppy, panda, fox, hedgehog, whale, acorn, umbrella, kite, snowGlobe, beachBall, candyCane, calendarPage, clipboard, pomodoro, deskLamp, stickyStack, briefcase, sheetMask, serum, yoga, sleepMask, bathBomb, youGotThis, bomDia, saudadeWord, gunaydin, cokGuzel

    var id: Self { self }

    /// Sections of the sticker drawer, in the order they're shown.
    enum Category: String, CaseIterable {
        case cute = "Tape & cute"
        case words = "Words"
        case vintage = "Vintage"
        case portugal = "Portugal 🇵🇹"
        case turkiye = "Türkiye 🇹🇷"
        case antalya = "Antalya ☀️"
        case food = "Food & café"
        case animals = "Animals"
        case faces = "Mood faces"
        case sky = "Sky & dreamy"
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

    /// Tapes, labels and notes you can write on.
    var isWritable: Bool {
        switch self {
        case .washiPink, .washiMint, .washiDots, .tag, .bannerToday, .bannerNotes, .labelTodo, .labelGoals, .labelMemo,
             .highlighterYellow, .highlighterPink, .polaroid, .ticket, .tornNote, .gridNote, .labelDeadline, .labelExam,
             .newspaperScrap, .kraftPaper, .quoteStrip, .typedWords, .envelopeHeart:
            true
        default:
            false
        }
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
        case .croissant, .boba, .iceCream, .donut, .avocado, .pizza, .lemon, .sushi:
            .food
        case .bunny, .bear, .frog, .chick, .bee, .ladybug:
            .animals
        case .shootingStar, .saturn, .twinkle, .cuteMoon, .rainCloud:
            .sky
        case .faceHappy, .faceLove, .faceSleepy, .faceSad, .faceAngry, .faceExcited:
            .faces
        case .nazar, .cay, .simit, .lokum:
            .turkiye
        case .portakal, .palmTree, .caretta, .hadrianGate, .yivliMinare, .gulet, .nar, .stampAntalya:
            .antalya
        case .chestnuts, .rainBoots, .snowman, .mitten, .hotChocolate, .sakura, .watermelon, .seashell, .icePop, .scarf:
            .seasons
        case .onigiri, .dango, .matchaLatte, .ramen, .baklava, .pancakes, .cookie, .cakeSlice:
            .food
        case .waxSealRose, .waxSealSprig, .envelopeHeart, .stampLavender, .stampFern, .newspaperScrap, .musicSheet, .kraftPaper,
             .butterflyNight, .butterflyCream, .driedLavender, .daisy, .typewriter, .satinBow, .plasterTape, .quoteStrip,
             .pressedFlower, .typedWords:
            .vintage
        case .turkishCoffee, .cezve, .balloon, .galataTower, .tulipTR, .seagull, .kilimTile, .stampIstanbul, .kunefe, .evilEyeHand:
            .turkiye
        case .vapur, .fairyChimney, .ayran, .mosque, .streetCat, .lahmacun:
            .turkiye
        case .vintageKey, .pocketWatch, .quillInk, .floralTeacup, .vintageCamera, .cassette:
            .vintage
        case .sleepyCat, .puppy, .panda, .fox, .hedgehog, .whale:
            .animals
        case .acorn, .umbrella, .kite, .snowGlobe, .beachBall, .candyCane:
            .seasons
        case .calendarPage, .clipboard, .pomodoro, .deskLamp, .stickyStack, .briefcase:
            .study
        case .sheetMask, .serum, .yoga, .sleepMask, .bathBomb, .youGotThis:
            .selfCare
        case .bomDia, .saudadeWord, .gunaydin, .cokGuzel:
            .words
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
        case .croissant: "Croissant"
        case .boba: "Bubble tea"
        case .iceCream: "Ice cream"
        case .donut: "Donut"
        case .avocado: "Avocado"
        case .pizza: "Pizza"
        case .lemon: "Lemon"
        case .sushi: "Sushi"
        case .bunny: "Bunny"
        case .bear: "Bear"
        case .frog: "Frog"
        case .chick: "Chick"
        case .bee: "Bee"
        case .ladybug: "Ladybug"
        case .shootingStar: "Shooting star"
        case .saturn: "Planet"
        case .twinkle: "Twinkle"
        case .cuteMoon: "Sleepy moon face"
        case .rainCloud: "Rain cloud"
        case .faceHappy: "Happy face"
        case .faceLove: "In love face"
        case .faceSleepy: "Sleepy face"
        case .faceSad: "Sad face"
        case .faceAngry: "Angry face"
        case .faceExcited: "Excited face"
        case .nazar: "Nazar"
        case .cay: "Turkish tea"
        case .simit: "Simit"
        case .lokum: "Lokum"
        case .portakal: "Antalya orange"
        case .palmTree: "Palm tree"
        case .caretta: "Caretta turtle"
        case .hadrianGate: "Hadrian's Gate"
        case .yivliMinare: "Yivli Minare"
        case .gulet: "Gulet"
        case .nar: "Pomegranate"
        case .stampAntalya: "Antalya stamp"
        case .chestnuts: "Chestnuts"
        case .rainBoots: "Rain boots"
        case .snowman: "Snowman"
        case .mitten: "Mitten"
        case .hotChocolate: "Hot chocolate"
        case .sakura: "Sakura branch"
        case .watermelon: "Watermelon"
        case .seashell: "Seashell"
        case .icePop: "Ice pop"
        case .scarf: "Scarf"
        case .onigiri: "Onigiri"
        case .dango: "Dango"
        case .matchaLatte: "Matcha latte"
        case .ramen: "Ramen"
        case .baklava: "Baklava"
        case .pancakes: "Pancakes"
        case .cookie: "Cookie"
        case .cakeSlice: "Cake slice"
        case .waxSealRose: "Wax seal with a rose"
        case .waxSealSprig: "Wax seal with a sprig"
        case .envelopeHeart: "Envelope with a heart"
        case .stampLavender: "Lavender stamp"
        case .stampFern: "Fern stamp"
        case .newspaperScrap: "Newspaper scrap"
        case .musicSheet: "Sheet music scrap"
        case .kraftPaper: "Kraft paper"
        case .butterflyNight: "Night butterfly"
        case .butterflyCream: "Cream butterfly"
        case .driedLavender: "Dried lavender"
        case .daisy: "Daisy"
        case .typewriter: "Typewriter"
        case .satinBow: "Satin bow"
        case .plasterTape: "Plaster tape"
        case .quoteStrip: "Typed quote"
        case .pressedFlower: "Pressed flower"
        case .typedWords: "Typed words"
        case .turkishCoffee: "Turkish coffee"
        case .cezve: "Cezve"
        case .balloon: "Cappadocia balloon"
        case .galataTower: "Galata Tower"
        case .tulipTR: "Lale"
        case .seagull: "Seagull"
        case .kilimTile: "Kilim pattern"
        case .stampIstanbul: "İstanbul stamp"
        case .kunefe: "Künefe"
        case .evilEyeHand: "Hamsa with nazar"
        case .vapur: "Vapur ferry"
        case .fairyChimney: "Fairy chimneys"
        case .ayran: "Ayran"
        case .mosque: "Mosque skyline"
        case .streetCat: "İstanbul street cat"
        case .lahmacun: "Lahmacun"
        case .vintageKey: "Old key"
        case .pocketWatch: "Pocket watch"
        case .quillInk: "Quill and ink"
        case .floralTeacup: "Floral teacup"
        case .vintageCamera: "Vintage camera"
        case .cassette: "Cassette"
        case .sleepyCat: "Sleeping cat"
        case .puppy: "Puppy"
        case .panda: "Panda"
        case .fox: "Fox"
        case .hedgehog: "Hedgehog"
        case .whale: "Whale"
        case .acorn: "Acorn"
        case .umbrella: "Umbrella"
        case .kite: "Kite"
        case .snowGlobe: "Snow globe"
        case .beachBall: "Beach ball"
        case .candyCane: "Candy cane"
        case .calendarPage: "Calendar page"
        case .clipboard: "Clipboard"
        case .pomodoro: "Pomodoro timer"
        case .deskLamp: "Desk lamp"
        case .stickyStack: "Sticky notes"
        case .briefcase: "Briefcase"
        case .sheetMask: "Sheet mask"
        case .serum: "Skincare"
        case .yoga: "Yoga"
        case .sleepMask: "Sleep mask"
        case .bathBomb: "Bath bomb"
        case .youGotThis: "You got this"
        case .bomDia: "bom dia"
        case .saudadeWord: "saudade"
        case .gunaydin: "günaydın"
        case .cokGuzel: "çok güzel"
        }
    }
}

struct DrawnStickerView: View {
    let sticker: DrawnSticker
    /// What's written on it, for writable stickers. Empty shows the sticker's own wording, if it has one.
    var text: String = ""

    var body: some View {
        switch sticker {
        case .washiPink:
            WashiTape(color: Color(red: 0.96, green: 0.70, blue: 0.75), pattern: .stripes).writing(text)
        case .washiMint:
            WashiTape(color: Color(red: 0.62, green: 0.85, blue: 0.76), pattern: .grid).writing(text)
        case .washiDots:
            WashiTape(color: Color(red: 0.98, green: 0.85, blue: 0.55), pattern: .dots).writing(text)
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
            Tag(text: text.isEmpty ? "♡ today" : text)
        default:
            BujoStickerView(sticker: sticker, text: text)
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
    /// Handwriting in ink across a sticker, for tapes and notes you've written on.
    func writing(_ text: String, size: CGFloat = 19, lines: Int = 1) -> some View {
        overlay {
            if !text.isEmpty {
                Text(text)
                    .font(Theme.handwriting(size: size).weight(.semibold))
                    .foregroundStyle(Theme.ink.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(lines)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 10)
            }
        }
    }

    /// A matte "flake" sticker, like Japanese sticker sheets: slightly softened colours,
    /// a thin cream kiss-cut edge and barely any shadow, so it sits on the paper instead of floating above it.
    func stickerOutline(_ width: CGFloat = 2) -> some View {
        let edge = Color(red: 0.995, green: 0.985, blue: 0.955)
        let w = width * 0.75
        return self
            .saturation(0.82)
            .shadow(color: edge, radius: 0, x: w, y: 0)
            .shadow(color: edge, radius: 0, x: -w, y: 0)
            .shadow(color: edge, radius: 0, x: 0, y: w)
            .shadow(color: edge, radius: 0, x: 0, y: -w)
            .shadow(color: Color(red: 0.35, green: 0.25, blue: 0.15).opacity(0.16), radius: 0.6, x: 0.4, y: 0.8)
    }
}

// MARK: - Shapes

private struct WashiTape: View {
    typealias Pattern = WashiPattern
    let color: Color
    let pattern: Pattern

    var body: some View {
        WashiPaper(color: color, pattern: pattern)
            .frame(width: 120, height: 30)
    }
}

/// Rectangle with torn zigzag edges on the left and right.
struct ZigzagEnds: Shape {
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
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.93, green: 0.86, blue: 0.72))
            HStack(spacing: 6) {
                Circle().stroke(Color(red: 0.55, green: 0.45, blue: 0.35), lineWidth: 1.2).frame(width: 7, height: 7)
                Text(text)
                    .font(Theme.serif(13, .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
