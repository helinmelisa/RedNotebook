import Foundation
import SwiftData

/// One page of the notebook, Hobonichi style: exactly one per day.
///
/// Every property has a default and relationships are optional so the store can sync with iCloud later.
@Model
final class DayPage {
    /// Start of the day this page belongs to.
    var day: Date = Date.now
    var diaryText: String = ""
    var mood: String?
    /// SF Symbol name of the weather icon.
    var weather: String?

    // What I ate. The four fixed lines are from before meals had times; MealsSection moves them into `meals`.
    @Relationship(deleteRule: .cascade, inverse: \MealEntry.page)
    var meals: [MealEntry]? = []
    var breakfast: String = ""
    var lunch: String = ""
    var dinner: String = ""
    var snacks: String = ""

    // Today's outfit
    /// Transparent PNG of the outfit, cut out of its background.
    @Attribute(.externalStorage) var outfitPhoto: Data?
    var outfitNote: String = ""

    /// Ids of the habits ticked off on this day (see `Habit`).
    var habitsDone: [String] = []
    /// The answer to the question of the day.
    var promptAnswer: String = ""
    /// Parts of the page taken off this day (see `DayPageContent.Part`).
    var hiddenParts: [String] = []

    /// Handwriting and doodles on the page (PencilKit drawing data).
    @Attribute(.externalStorage) var drawing: Data?
    /// Handwriting and doodles on the day's dotted diary page.
    @Attribute(.externalStorage) var diaryDrawing: Data?

    /// Clothes from the closet worn on this day.
    @Relationship(deleteRule: .nullify, inverse: \ClothingItem.days)
    var outfitItems: [ClothingItem]? = []

    @Relationship(deleteRule: .cascade, inverse: \BulletItem.page)
    var items: [BulletItem]? = []

    @Relationship(deleteRule: .cascade, inverse: \QuickNote.page)
    var notes: [QuickNote]? = []

    @Relationship(deleteRule: .cascade, inverse: \StickerPlacement.page)
    var stickers: [StickerPlacement]? = []

    init(day: Date) {
        self.day = Calendar.current.startOfDay(for: day)
    }

    var sortedItems: [BulletItem] {
        (items ?? []).sorted { $0.order < $1.order }
    }

    var sortedMeals: [MealEntry] {
        (meals ?? []).sorted { $0.time < $1.time }
    }

    var sortedNotes: [QuickNote] {
        (notes ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    /// Every sticker on the day, on the Today page and the diary page.
    var sortedStickers: [StickerPlacement] {
        (stickers ?? []).sorted { $0.z < $1.z }
    }

    func stickers(onDiary: Bool) -> [StickerPlacement] {
        sortedStickers.filter { $0.onDiary == onDiary }
    }

    /// Worn clothes in the order they're layered on the body.
    var wornItems: [ClothingItem] {
        (outfitItems ?? []).sorted { $0.category.layer < $1.category.layer }
    }

    var isEmpty: Bool {
        diaryText.isEmpty && mood == nil && weather == nil && habitsDone.isEmpty && promptAnswer.isEmpty
            && (items ?? []).isEmpty && (notes ?? []).isEmpty && (stickers ?? []).isEmpty
            && [breakfast, lunch, dinner, snacks, outfitNote].allSatisfy(\.isEmpty) && outfitPhoto == nil
            && (outfitItems ?? []).isEmpty && drawing == nil && diaryDrawing == nil && (meals ?? []).isEmpty
    }
}

extension DayPage {
    /// Returns the page for `day`, creating it if it doesn't exist yet.
    static func page(for day: Date, in context: ModelContext) -> DayPage {
        let start = Calendar.current.startOfDay(for: day)
        var descriptor = FetchDescriptor<DayPage>(predicate: #Predicate { $0.day == start })
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let page = DayPage(day: start)
        context.insert(page)
        return page
    }
}
