import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// The whole notebook as one JSON file (photos included), to keep in iCloud Drive or Files and restore from.
struct NotebookBackup: Codable {
    var version = 1
    var createdAt = Date.now
    var pages: [Page] = []
    var photoStickers: [Data] = []
    var clothes: [Clothing] = []
    var bodyPhotos: [Data] = []
    /// Settings kept outside the database (optional, so older backups still read).
    var habits: String?
    var countdowns: String?
    var knownWords: String?

    static let lastBackupKey = "lastBackupDate"

    struct Page: Codable {
        var day: Date
        var diaryText: String
        var mood: String?
        var weather: String?
        var habitsDone: [String]
        var promptAnswer: String
        var outfitPhoto: Data?
        var outfitNote: String
        var drawing: Data?
        /// Indexes into `clothes`.
        var outfitItems: [Int]
        var items: [Item]
        var meals: [Meal]
        var notes: [Note]
        var stickers: [Sticker]
        var breakfast, lunch, dinner, snacks: String
    }

    struct Item: Codable {
        var text: String
        var kind: String
        var state: String
        var order: Int
        var createdAt: Date
    }

    struct Meal: Codable {
        var time: Date
        var text: String
    }

    struct Note: Codable {
        var text: String
        var colorIndex: Int
        var createdAt: Date
    }

    struct Sticker: Codable {
        var kind: String
        var value: String
        var x, y, scale, rotation: Double
        var z: Int
        var createdAt: Date
        var text: String
        var imageData: Data?
        var extraImages: [Data]?
        /// Index into `photoStickers`.
        var photo: Int?
    }

    struct Clothing: Codable {
        var imageData: Data?
        var category: String
        var createdAt: Date
        var fitX, fitTop, fitWidth: Double
    }
}

// MARK: - Making a backup

extension NotebookBackup {
    /// Everything in the notebook, plus to-dos with no day yet ("someday").
    @MainActor
    static func make(from context: ModelContext) throws -> NotebookBackup {
        var backup = NotebookBackup()

        let photoStickers = try context.fetch(FetchDescriptor<PhotoSticker>(sortBy: [SortDescriptor(\.createdAt)]))
        let photoIndex = Dictionary(uniqueKeysWithValues: photoStickers.enumerated().map { ($1.persistentModelID, $0) })
        backup.photoStickers = photoStickers.map { $0.imageData ?? Data() }

        let clothes = try context.fetch(FetchDescriptor<ClothingItem>(sortBy: [SortDescriptor(\.createdAt)]))
        let clothingIndex = Dictionary(uniqueKeysWithValues: clothes.enumerated().map { ($1.persistentModelID, $0) })
        backup.clothes = clothes.map {
            Clothing(imageData: $0.imageData, category: $0.categoryRaw, createdAt: $0.createdAt,
                     fitX: $0.fitX, fitTop: $0.fitTop, fitWidth: $0.fitWidth)
        }

        backup.bodyPhotos = try context.fetch(FetchDescriptor<BodyPhoto>()).compactMap(\.imageData)
        let defaults = UserDefaults.standard
        backup.habits = defaults.string(forKey: Habit.storageKey)
        backup.countdowns = defaults.string(forKey: Countdown.storageKey)
        backup.knownWords = defaults.string(forKey: WordDeck.knownKey)

        for page in try context.fetch(FetchDescriptor<DayPage>(sortBy: [SortDescriptor(\.day)])) where !page.isEmpty {
            backup.pages.append(Page(
                day: page.day, diaryText: page.diaryText, mood: page.mood, weather: page.weather,
                habitsDone: page.habitsDone, promptAnswer: page.promptAnswer,
                outfitPhoto: page.outfitPhoto, outfitNote: page.outfitNote, drawing: page.drawing,
                outfitItems: (page.outfitItems ?? []).compactMap { clothingIndex[$0.persistentModelID] },
                items: page.sortedItems.map(Item.init),
                meals: page.sortedMeals.map { Meal(time: $0.time, text: $0.text) },
                notes: page.sortedNotes.map { Note(text: $0.text, colorIndex: $0.colorIndex, createdAt: $0.createdAt) },
                stickers: page.sortedStickers.map { sticker in
                    Sticker(kind: sticker.kindRaw, value: sticker.value, x: sticker.x, y: sticker.y,
                            scale: sticker.scale, rotation: sticker.rotation, z: sticker.z,
                            createdAt: sticker.createdAt, text: sticker.text, imageData: sticker.imageData,
                            extraImages: sticker.extraImages,
                            photo: sticker.photo.flatMap { photoIndex[$0.persistentModelID] })
                },
                breakfast: page.breakfast, lunch: page.lunch, dinner: page.dinner, snacks: page.snacks
            ))
        }

        // Someday to-dos live on no page; keep them on a page dated distantPast
        let someday = try context.fetch(FetchDescriptor<BulletItem>(predicate: #Predicate { $0.page == nil }))
        if !someday.isEmpty {
            backup.pages.append(Page(day: .distantPast, diaryText: "", habitsDone: [], promptAnswer: "",
                                     outfitNote: "", outfitItems: [], items: someday.map(Item.init),
                                     meals: [], notes: [], stickers: [],
                                     breakfast: "", lunch: "", dinner: "", snacks: ""))
        }
        return backup
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    static func decode(_ data: Data) throws -> NotebookBackup {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(NotebookBackup.self, from: data)
    }

    static var fileName: String {
        "helin's notebook " + Date.now.formatted(.iso8601.year().month().day())
    }
}

private extension NotebookBackup.Item {
    init(_ item: BulletItem) {
        self.init(text: item.text, kind: item.kindRaw, state: item.stateRaw, order: item.order, createdAt: item.createdAt)
    }
}

// MARK: - Restoring

extension NotebookBackup {
    /// Replaces everything in the notebook with this backup.
    @MainActor
    func restore(into context: ModelContext) throws {
        for page in try context.fetch(FetchDescriptor<DayPage>()) { context.delete(page) }
        for sticker in try context.fetch(FetchDescriptor<PhotoSticker>()) { context.delete(sticker) }
        for piece in try context.fetch(FetchDescriptor<ClothingItem>()) { context.delete(piece) }
        for photo in try context.fetch(FetchDescriptor<BodyPhoto>()) { context.delete(photo) }
        try context.save()
        // Someday to-dos, and anything else the cascades left without a page
        for item in try context.fetch(FetchDescriptor<BulletItem>()) { context.delete(item) }
        for meal in try context.fetch(FetchDescriptor<MealEntry>()) { context.delete(meal) }
        for note in try context.fetch(FetchDescriptor<QuickNote>()) { context.delete(note) }
        for sticker in try context.fetch(FetchDescriptor<StickerPlacement>()) { context.delete(sticker) }
        try context.save()

        let photoStickers = photoStickers.map { data in
            let sticker = PhotoSticker(imageData: data)
            context.insert(sticker)
            return sticker
        }
        let clothes = clothes.map { saved in
            let piece = ClothingItem(imageData: saved.imageData ?? Data(),
                                     category: ClothingCategory(rawValue: saved.category) ?? .top)
            piece.createdAt = saved.createdAt
            piece.fitX = saved.fitX
            piece.fitTop = saved.fitTop
            piece.fitWidth = saved.fitWidth
            context.insert(piece)
            return piece
        }
        for data in bodyPhotos { context.insert(BodyPhoto(imageData: data)) }
        let defaults = UserDefaults.standard
        for (key, value) in [(Habit.storageKey, habits), (Countdown.storageKey, countdowns), (WordDeck.knownKey, knownWords)] {
            if let value { defaults.set(value, forKey: key) }
        }

        for saved in pages {
            func makeItem(_ savedItem: Item) -> BulletItem {
                let item = BulletItem(text: savedItem.text, kind: BulletKind(rawValue: savedItem.kind) ?? .task, order: savedItem.order)
                item.stateRaw = savedItem.state
                item.createdAt = savedItem.createdAt
                context.insert(item)
                return item
            }

            if saved.day == .distantPast {
                saved.items.forEach { _ = makeItem($0) }
                continue
            }

            let page = DayPage(day: saved.day)
            context.insert(page)
            page.diaryText = saved.diaryText
            page.mood = saved.mood
            page.weather = saved.weather
            page.habitsDone = saved.habitsDone
            page.promptAnswer = saved.promptAnswer
            page.outfitPhoto = saved.outfitPhoto
            page.outfitNote = saved.outfitNote
            page.drawing = saved.drawing
            page.breakfast = saved.breakfast
            page.lunch = saved.lunch
            page.dinner = saved.dinner
            page.snacks = saved.snacks
            page.outfitItems = saved.outfitItems.filter { clothes.indices.contains($0) }.map { clothes[$0] }

            for savedItem in saved.items { makeItem(savedItem).page = page }
            for meal in saved.meals {
                let entry = MealEntry(time: meal.time, text: meal.text)
                context.insert(entry)
                entry.page = page
            }
            for savedNote in saved.notes {
                let note = QuickNote(text: savedNote.text, colorIndex: savedNote.colorIndex)
                note.createdAt = savedNote.createdAt
                context.insert(note)
                note.page = page
            }
            for savedSticker in saved.stickers {
                let sticker = StickerPlacement(choice: .emoji(""), x: savedSticker.x, y: savedSticker.y,
                                               rotation: savedSticker.rotation, z: savedSticker.z)
                sticker.kindRaw = savedSticker.kind
                sticker.value = savedSticker.value
                sticker.scale = savedSticker.scale
                sticker.createdAt = savedSticker.createdAt
                sticker.text = savedSticker.text
                sticker.imageData = savedSticker.imageData
                sticker.extraImages = savedSticker.extraImages
                context.insert(sticker)
                sticker.page = page
                if let index = savedSticker.photo, photoStickers.indices.contains(index) {
                    sticker.photo = photoStickers[index]
                }
            }
        }
        try context.save()
    }
}

// MARK: - Files

/// A finished file (backup or PDF) for the share sheet / Files exporter.
struct ExportedFile: FileDocument {
    static let readableContentTypes: [UTType] = [.json, .pdf]

    let data: Data
    let contentType: UTType

    init(data: Data, contentType: UTType) {
        self.data = data
        self.contentType = contentType
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
        contentType = configuration.contentType
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
