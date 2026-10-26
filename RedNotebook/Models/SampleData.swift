#if DEBUG
import Foundation
import SwiftData
import SwiftUI

/// Example content for SwiftUI previews and screenshots (launch with `--sample-data`).
enum SampleData {
    @MainActor
    static let container: ModelContainer = {
        let container = try! ModelContainer(for: DayPage.self, PhotoSticker.self, ClothingItem.self, BodyPhoto.self,
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

        // Memories for "On this day", and some habit history for Year in pixels
        let calendar = Calendar.current
        for (offset, mood, text) in [(DateComponents(year: -1), "🥰", "First week in Porto! Walked along the Douro at sunset and ate a francesinha."),
                                     (DateComponents(month: -1), "😊", "Thesis meeting went well, then coffee with Ana at Majestic.")] {
            guard let day = calendar.date(byAdding: offset, to: .now) else { continue }
            let memory = DayPage.page(for: day, in: context)
            if memory.isEmpty {
                memory.mood = mood
                memory.diaryText = text
            }
        }
        for offset in -40...0 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: .now) else { continue }
            let page = DayPage.page(for: day, in: context)
            if page.habitsDone.isEmpty {
                page.habitsDone = Habit.defaults.map(\.id).filter { _ in Bool.random() }
                if offset > -9 { page.habitsDone.append("water") }
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
        if (page.meals ?? []).isEmpty && page.breakfast.isEmpty {
            for (hour, minute, text) in [(8, 45, "Pastel de nata + galão"), (13, 15, "Francesinha with friends"),
                                         (16, 30, "Apple"), (20, 0, "Soup and bread")] {
                let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: page.day)!
                let meal = MealEntry(time: time, text: text)
                context.insert(meal)
                meal.page = page
            }
            page.outfitNote = "White shirt, mom jeans, red scarf"
        }
        if (page.stickers ?? []).isEmpty {
            let examples: [(StickerChoice, Double, Double, Double)] = [
                (.drawn(.washiPink), 0.78, 600, 6),
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

    /// A drawn figure and a few drawn clothes, so the closet can be tried without real photos.
    @MainActor
    static func fillCloset(_ context: ModelContext) {
        guard (try? context.fetchCount(FetchDescriptor<ClothingItem>())) == 0 else { return }

        func png<V: View>(_ view: V) -> Data? {
            let renderer = ImageRenderer(content: view)
            renderer.scale = 2
            return renderer.uiImage?.pngData()
        }

        if let body = png(Image(systemName: "figure.stand").resizable().scaledToFit()
            .foregroundStyle(Color(red: 0.87, green: 0.70, blue: 0.58)).frame(width: 180, height: 300)) {
            context.insert(BodyPhoto(imageData: body))
        }

        let tee = png(TeeShape().fill(Color(red: 0.95, green: 0.55, blue: 0.65)).frame(width: 120, height: 90))
        let stripes = png(TeeShape().fill(Color(red: 0.98, green: 0.97, blue: 0.92))
            .overlay(TeeShape().stroke(Color(red: 0.2, green: 0.3, blue: 0.6), lineWidth: 2)).frame(width: 120, height: 90))
        let skirt = png(SkirtShape().fill(Color(red: 0.35, green: 0.45, blue: 0.70)).frame(width: 90, height: 80))
        let shoes = png(HStack(spacing: 16) {
            Capsule().fill(Theme.red).frame(width: 34, height: 14)
            Capsule().fill(Theme.red).frame(width: 34, height: 14)
        })

        let page = DayPage.page(for: .now, in: context)
        for (data, category, wear) in [(tee, ClothingCategory.top, true), (stripes, .top, false),
                                       (skirt, .bottom, true), (shoes, .shoes, true)] {
            guard let data else { continue }
            let piece = ClothingItem(imageData: data, category: category)
            context.insert(piece)
            if wear { page.outfitItems = (page.outfitItems ?? []) + [piece] }
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

private struct TeeShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.width * 0.35, y: 0))
        p.addQuadCurve(to: CGPoint(x: r.width * 0.65, y: 0), control: CGPoint(x: r.midX, y: r.height * 0.15))
        p.addLine(to: CGPoint(x: r.width, y: r.height * 0.2))
        p.addLine(to: CGPoint(x: r.width * 0.88, y: r.height * 0.42))
        p.addLine(to: CGPoint(x: r.width * 0.76, y: r.height * 0.36))
        p.addLine(to: CGPoint(x: r.width * 0.76, y: r.height))
        p.addLine(to: CGPoint(x: r.width * 0.24, y: r.height))
        p.addLine(to: CGPoint(x: r.width * 0.24, y: r.height * 0.36))
        p.addLine(to: CGPoint(x: r.width * 0.12, y: r.height * 0.42))
        p.addLine(to: CGPoint(x: 0, y: r.height * 0.2))
        p.closeSubpath()
        return p
    }
}

private struct SkirtShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.width * 0.2, y: 0))
        p.addLine(to: CGPoint(x: r.width * 0.8, y: 0))
        p.addLine(to: CGPoint(x: r.width, y: r.height))
        p.addLine(to: CGPoint(x: 0, y: r.height))
        p.closeSubpath()
        return p
    }
}
#endif
