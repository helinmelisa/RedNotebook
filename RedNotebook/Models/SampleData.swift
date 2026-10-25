#if DEBUG
import Foundation
import SwiftData

/// Example content for SwiftUI previews and screenshots (launch with `--sample-data`).
enum SampleData {
    @MainActor
    static let container: ModelContainer = {
        let container = try! ModelContainer(for: DayPage.self, PhotoSticker.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        fill(container.mainContext)
        return container
    }()

    static func fill(_ context: ModelContext) {
        // A few earlier days so the calendar shows moods and dots
        for (offset, mood) in [(-1, "🥰"), (-3, "😴"), (-6, "🙂")] {
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: .now) else { continue }
            let earlier = DayPage.page(for: day, in: context)
            if earlier.isEmpty {
                earlier.mood = mood
                earlier.diaryText = "A good day."
                if offset == -3 {
                    BulletItem(text: "Return library books", kind: .task, order: 0).page = earlier
                }
            }
        }

        // Someday tasks have no page
        let someday = FetchDescriptor<BulletItem>(predicate: #Predicate { $0.page == nil })
        if (try? context.fetchCount(someday)) == 0 {
            for text in ["Learn watercolour", "Reorganise bookshelf"] {
                context.insert(BulletItem(text: text, kind: .task, order: 0))
            }
        }

        let page = DayPage.page(for: .now, in: context)
        if (page.stickers ?? []).isEmpty {
            let examples: [(StickerChoice, Double, Double, Double)] = [
                (.drawn(.washiPink), 0.45, 12, -4),
                (.drawn(.flower), 0.85, 470, -10),
                (.emoji("☕️"), 0.8, 760, 12),
            ]
            for (index, example) in examples.enumerated() {
                let placement = StickerPlacement(choice: example.0, x: example.1, y: example.2,
                                                 rotation: example.3, z: index)
                context.insert(placement)
                placement.page = page
            }
        }
        guard page.isEmpty else { return }

        page.mood = "😊"
        page.weather = "cloud.sun"
        page.diaryText = "Slow Sunday. Coffee at the window, then a long walk by the river. Started planning this notebook app!"

        let lines: [(String, BulletKind, BulletState)] = [
            ("Buy a gift for mom", .task, .open),
            ("Call the dentist", .task, .done),
            ("Dinner with Ana 19:00", .event, .open),
            ("Idea: new figure for the thesis", .note, .open),
        ]
        for (index, line) in lines.enumerated() {
            let item = BulletItem(text: line.0, kind: line.1, order: index)
            item.state = line.2
            item.page = page
        }

        for (index, text) in ["Water the plants 🌱", "Book train tickets"].enumerated() {
            QuickNote(text: text, colorIndex: index).page = page
        }
    }

    /// Adds example events to the calendar, only on the simulator so a real calendar is never touched.
    @MainActor
    static func fillCalendar(_ store: CalendarStore) async {
        #if targetEnvironment(simulator)
        if store.canAsk { await store.requestAccess() }
        guard store.hasAccess, store.events(on: .now).isEmpty else { return }

        let calendar = Calendar.current
        let examples: [(String, Int, Int)] = [("Dinner with Ana", 0, 19), ("Thesis meeting", 1, 10), ("Gym", 2, 18), ("Lunch with Bosch team", 4, 12)]
        for (title, dayOffset, hour) in examples {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: .now),
                  let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { continue }
            try? store.addEvent(title: title, start: start, end: start.addingTimeInterval(3600),
                                isAllDay: false, calendar: nil)
        }
        #endif
    }
}
#endif
