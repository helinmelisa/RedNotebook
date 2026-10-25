import Foundation
import SwiftData

/// Something eaten on a day, and when.
@Model
final class MealEntry {
    var time: Date = Date.now
    var text: String = ""
    var page: DayPage?

    init(time: Date, text: String = "") {
        self.time = time
        self.text = text
    }

    /// Which meal this probably was, from the time of day.
    var kind: MealKind {
        MealKind(hour: Calendar.current.component(.hour, from: time))
    }
}

enum MealKind {
    case breakfast, lunch, snack, dinner, lateNight

    init(hour: Int) {
        switch hour {
        case 5..<11: self = .breakfast
        case 11..<15: self = .lunch
        case 15..<18: self = .snack
        case 18..<23: self = .dinner
        default: self = .lateNight
        }
    }

    var emoji: String {
        switch self {
        case .breakfast: "🥐"
        case .lunch: "🥗"
        case .snack: "🍪"
        case .dinner: "🍝"
        case .lateNight: "🌙"
        }
    }

    var name: String {
        switch self {
        case .breakfast: "Breakfast"
        case .lunch: "Lunch"
        case .snack: "Snack"
        case .dinner: "Dinner"
        case .lateNight: "Late night"
        }
    }
}
