import SwiftUI

/// The moods you can pick for a day, and the colour each one paints the calendar.
enum Moods {
    static let all = ["🥰", "😊", "🙂", "😐", "😔", "😢", "😡", "😴"]

    static func name(_ mood: String) -> String {
        switch mood {
        case "🥰": "In love"
        case "😊": "Happy"
        case "🙂": "Good"
        case "😐": "Okay"
        case "😔": "Down"
        case "😢": "Sad"
        case "😡": "Angry"
        case "😴": "Tired"
        default: mood
        }
    }

    static func color(_ mood: String) -> Color {
        switch mood {
        case "🥰": Color(red: 0.97, green: 0.62, blue: 0.72)
        case "😊": Color(red: 1.00, green: 0.80, blue: 0.35)
        case "🙂": Color(red: 0.62, green: 0.82, blue: 0.55)
        case "😐": Color(red: 0.78, green: 0.76, blue: 0.70)
        case "😔": Color(red: 0.60, green: 0.68, blue: 0.80)
        case "😢": Color(red: 0.45, green: 0.62, blue: 0.92)
        case "😡": Color(red: 0.92, green: 0.40, blue: 0.35)
        case "😴": Color(red: 0.72, green: 0.65, blue: 0.90)
        default: Theme.hairline
        }
    }
}
