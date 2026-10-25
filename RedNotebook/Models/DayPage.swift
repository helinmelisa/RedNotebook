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

    // What I ate
    var breakfast: String = ""
    var lunch: String = ""
    var dinner: String = ""
    var snacks: String = ""

    // Today's outfit
    /// Transparent PNG of the outfit, cut out of its background.
    @Attribute(.externalStorage) var outfitPhoto: Data?
    var outfitNote: String = ""

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

    var sortedNotes: [QuickNote] {
        (notes ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var sortedStickers: [StickerPlacement] {
        (stickers ?? []).sorted { $0.z < $1.z }
    }

    var isEmpty: Bool {
        diaryText.isEmpty && mood == nil && weather == nil
            && (items ?? []).isEmpty && (notes ?? []).isEmpty && (stickers ?? []).isEmpty
            && [breakfast, lunch, dinner, snacks, outfitNote].allSatisfy(\.isEmpty) && outfitPhoto == nil
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
