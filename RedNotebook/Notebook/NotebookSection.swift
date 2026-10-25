import SwiftUI

/// The index tabs along the right edge of the notebook.
enum NotebookSection: String, CaseIterable, Identifiable {
    case today, calendar, todo, diary, stickers

    var id: Self { self }

    var title: String {
        switch self {
        case .today: "Today"
        case .calendar: "Calendar"
        case .todo: "To-Do"
        case .diary: "Diary"
        case .stickers: "Stickers"
        }
    }

    var icon: String {
        switch self {
        case .today: "sun.max"
        case .calendar: "calendar"
        case .todo: "checklist"
        case .diary: "book.closed"
        case .stickers: "star"
        }
    }

    /// Each tab gets its own muted colour, like coloured index stickers.
    var tabColor: Color {
        switch self {
        case .today: Color(red: 0.93, green: 0.76, blue: 0.42)
        case .calendar: Color(red: 0.55, green: 0.72, blue: 0.80)
        case .todo: Color(red: 0.62, green: 0.78, blue: 0.60)
        case .diary: Color(red: 0.88, green: 0.62, blue: 0.62)
        case .stickers: Color(red: 0.74, green: 0.66, blue: 0.84)
        }
    }
}
