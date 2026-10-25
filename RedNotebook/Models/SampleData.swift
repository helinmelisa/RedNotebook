#if DEBUG
import Foundation
import SwiftData

/// Example content for SwiftUI previews and screenshots (launch with `--sample-data`).
enum SampleData {
    @MainActor
    static let container: ModelContainer = {
        let container = try! ModelContainer(for: DayPage.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        fill(container.mainContext)
        return container
    }()

    static func fill(_ context: ModelContext) {
        let page = DayPage.page(for: .now, in: context)
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
}
#endif
