import Foundation
import SwiftData

enum BulletKind: String, CaseIterable, Identifiable {
    case task, event, note

    var id: Self { self }

    var name: String {
        switch self {
        case .task: "Task"
        case .event: "Event"
        case .note: "Note"
        }
    }

    var placeholder: String {
        switch self {
        case .task: "Add a task…"
        case .event: "Add an event…"
        case .note: "Add a note…"
        }
    }
}

enum BulletState: String {
    case open, done, migrated, cancelled
}

/// A bullet journal line: `•` task, `×` done, `>` migrated, `○` event, `–` note.
@Model
final class BulletItem {
    var text: String = ""
    var kindRaw: String = BulletKind.task.rawValue
    var stateRaw: String = BulletState.open.rawValue
    var order: Int = 0
    var createdAt: Date = Date.now
    var page: DayPage?

    init(text: String, kind: BulletKind, order: Int) {
        self.text = text
        self.kindRaw = kind.rawValue
        self.order = order
    }

    var kind: BulletKind {
        get { BulletKind(rawValue: kindRaw) ?? .task }
        set { kindRaw = newValue.rawValue }
    }

    var state: BulletState {
        get { BulletState(rawValue: stateRaw) ?? .open }
        set { stateRaw = newValue.rawValue }
    }

    var symbol: String {
        switch kind {
        case .event: return "○"
        case .note: return "–"
        case .task:
            switch state {
            case .open, .cancelled: return "•"
            case .done: return "×"
            case .migrated: return ">"
            }
        }
    }

    /// Done, migrated and cancelled lines are drawn faded.
    var isSettled: Bool { state != .open }
}
