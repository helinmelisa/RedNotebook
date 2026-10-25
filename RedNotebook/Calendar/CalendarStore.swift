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
    /// Calendars the user has switched off in the notebook (they stay untouched in the Calendar app).
    private(set) var hiddenCalendarIDs: Set<String> {
        didSet { UserDefaults.standard.set(Array(hiddenCalendarIDs), forKey: Self.hiddenKey) }
    }

    private static let hiddenKey = "hiddenCalendarIDs"
    private static let defaultsAppliedKey = "hiddenCalendarDefaultsApplied"

    init() {
        hiddenCalendarIDs = Set(UserDefaults.standard.stringArray(forKey: Self.hiddenKey) ?? [])
        NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: eventStore,
                                               queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.changeCount += 1 }
        }
        hideForeignHolidayCalendarsOnce()
    }

    var hasAccess: Bool { status == .fullAccess }
    var canAsk: Bool { status == .notDetermined }

    func requestAccess() async {
        _ = try? await eventStore.requestFullAccessToEvents()
        status = EKEventStore.authorizationStatus(for: .event)
        hideForeignHolidayCalendarsOnce()
        changeCount += 1
    }

    var allCalendars: [EKCalendar] {
        _ = changeCount
        guard hasAccess else { return [] }
        return eventStore.calendars(for: .event).sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
    }

    func isVisible(_ calendar: EKCalendar) -> Bool {
        !hiddenCalendarIDs.contains(calendar.calendarIdentifier)
    }

    func setVisible(_ visible: Bool, _ calendar: EKCalendar) {
        if visible {
            hiddenCalendarIDs.remove(calendar.calendarIdentifier)
        } else {
            hiddenCalendarIDs.insert(calendar.calendarIdentifier)
        }
    }

    /// The notebook has Portuguese holidays built in, so Turkish holiday calendars start hidden.
    private func hideForeignHolidayCalendarsOnce() {
        guard hasAccess, !UserDefaults.standard.bool(forKey: Self.defaultsAppliedKey) else { return }
        let keywords = ["turk", "türk", "tatil"]
        for calendar in eventStore.calendars(for: .event)
        where keywords.contains(where: { calendar.title.localizedCaseInsensitiveContains($0) }) {
            hiddenCalendarIDs.insert(calendar.calendarIdentifier)
        }
        UserDefaults.standard.set(true, forKey: Self.defaultsAppliedKey)
    }

    /// Events overlapping the given range, earliest first.
    func events(from start: Date, to end: Date) -> [EKEvent] {
        _ = changeCount // register an observation dependency
        guard hasAccess else { return [] }
        let visible = eventStore.calendars(for: .event).filter(isVisible)
        guard !visible.isEmpty else { return [] }
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: visible)
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
