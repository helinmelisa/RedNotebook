import Foundation
import SwiftData

/// A small sticky note about the day.
@Model
final class QuickNote {
    var text: String = ""
    var colorIndex: Int = 0
    var createdAt: Date = Date.now
    var page: DayPage?

    init(text: String = "", colorIndex: Int) {
        self.text = text
        self.colorIndex = colorIndex
    }
}
