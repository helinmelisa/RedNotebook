import EventKit
import SwiftUI
import SwiftData

/// Calendar events and notebook bullets for one day, shown under the month grid.
struct DayAgenda: View {
    let day: Date
    var onOpenDay: (Date) -> Void

    @Environment(CalendarStore.self) private var calendarStore
    @Query private var pages: [DayPage]

    init(day: Date, onOpenDay: @escaping (Date) -> Void) {
        self.day = day
        self.onOpenDay = onOpenDay
        let start = Calendar.current.startOfDay(for: day)
        _pages = Query(filter: #Predicate<DayPage> { $0.day == start })
    }

    var body: some View {
        let events = calendarStore.events(on: day)
        let items = pages.first?.sortedItems ?? []

        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(day.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Button { onOpenDay(day) } label: {
                    Label("Open page", systemImage: "arrow.right")
                        .labelStyle(TrailingIconLabelStyle())
                }
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(Theme.coverRed)
            }
            Rectangle().fill(Theme.ink.opacity(0.15)).frame(height: 0.5)

            if events.isEmpty && items.isEmpty {
                Text("Nothing planned")
                    .font(.system(size: 14, design: .serif).italic())
                    .foregroundStyle(Theme.ink.opacity(0.45))
            }

            ForEach(events, id: \.calendarItemIdentifier) { event in
                EventLine(event: event)
            }

            ForEach(items) { item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(item.symbol)
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 16)
                    Text(item.text)
                        .font(.system(size: 14, design: .serif))
                        .strikethrough(item.state == .cancelled)
                }
                .foregroundStyle(Theme.ink.opacity(item.isSettled ? 0.45 : 1))
            }
        }
    }
}

/// One iPhone Calendar event: coloured bar, time and title. Long-press to delete it.
struct EventLine: View {
    let event: EKEvent

    @Environment(CalendarStore.self) private var calendarStore

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            RoundedRectangle(cornerRadius: 1)
                .fill(event.color)
                .frame(width: 3, height: 14)
            Text(event.timeLabel)
                .font(.system(size: 12, design: .serif).monospacedDigit())
                .foregroundStyle(Theme.ink.opacity(0.55))
                .frame(width: 56, alignment: .leading)
            Text(event.title ?? "")
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(Theme.ink)
        }
        .contextMenu {
            if event.calendar.allowsContentModifications {
                Button("Delete from Calendar", systemImage: "trash", role: .destructive) {
                    try? calendarStore.delete(event)
                }
            }
        }
    }
}

private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}
