import EventKit
import Observation
import SwiftUI

/// Wraps EventKit so the notebook can read and write events in the iPhone Calendar.
@MainActor
@Observable
final class CalendarStore {
    let eventStore = EKEventStore()
    private(set) var status = EKEventStore.authorizationStatus(for: .event)
    /// Bumped whenever the system calendar changes, so views reading events refresh.
    private(set) var changeCount = 0

    init() {
        NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: eventStore,
                                               queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.changeCount += 1 }
        }
    }

    var hasAccess: Bool { status == .fullAccess }
    var canAsk: Bool { status == .notDetermined }

    func requestAccess() async {
        _ = try? await eventStore.requestFullAccessToEvents()
        status = EKEventStore.authorizationStatus(for: .event)
        changeCount += 1
    }

    /// Events overlapping the given range, earliest first.
    func events(from start: Date, to end: Date) -> [EKEvent] {
        _ = changeCount // register an observation dependency
        guard hasAccess else { return [] }
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
    }

    func events(on day: Date) -> [EKEvent] {
        let start = Calendar.current.startOfDay(for: day)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return events(from: start, to: end)
    }

    var writableCalendars: [EKCalendar] {
        eventStore.calendars(for: .event).filter(\.allowsContentModifications)
    }

    var defaultCalendar: EKCalendar? {
        eventStore.defaultCalendarForNewEvents
    }

    func addEvent(title: String, start: Date, end: Date, isAllDay: Bool, calendar: EKCalendar?) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = start
        event.endDate = end
        event.isAllDay = isAllDay
        event.calendar = calendar ?? defaultCalendar
        try eventStore.save(event, span: .thisEvent)
        changeCount += 1
    }

    func delete(_ event: EKEvent) throws {
        try eventStore.remove(event, span: .thisEvent)
        changeCount += 1
    }
}

extension EKEvent {
    var color: Color { Color(cgColor: calendar.cgColor) }

    var timeLabel: String {
        isAllDay ? "All day" : startDate.formatted(date: .omitted, time: .shortened)
    }
}
