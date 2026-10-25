import EventKit
import SwiftUI
import SwiftData

/// Hobonichi-style weekly agenda: one row per day with events, mood and the first bullets.
struct WeekView: View {
    @Binding var selectedDay: Date
    var onOpenDay: (Date) -> Void

    var body: some View {
        let week = Calendar.current.week(containing: selectedDay)

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("WEEK \(Calendar.current.component(.weekOfYear, from: selectedDay))")
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .tracking(2)
                        .foregroundStyle(Theme.coverRed)
                    Text(rangeTitle(week))
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                }
                Spacer()
                HStack(spacing: 14) {
                    Button { flip(by: -1) } label: { Image(systemName: "chevron.left") }
                        .accessibilityLabel("Previous week")
                    Button { flip(by: 1) } label: { Image(systemName: "chevron.right") }
                        .accessibilityLabel("Next week")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.ink.opacity(0.5))
            }

            if let first = week.first, let last = week.last {
                WeekRows(week: week, start: first,
                         end: Calendar.current.date(byAdding: .day, value: 1, to: last)!,
                         onOpenDay: onOpenDay)
            }
        }
    }

    private func rangeTitle(_ week: [Date]) -> String {
        guard let first = week.first, let last = week.last else { return "" }
        return "\(first.formatted(.dateTime.day().month(.abbreviated))) – \(last.formatted(.dateTime.day().month(.abbreviated)))"
    }

    private func flip(by weeks: Int) {
        guard let target = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: selectedDay) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.easeInOut(duration: 0.25)) { selectedDay = target }
    }
}

private struct WeekRows: View {
    let week: [Date]
    var onOpenDay: (Date) -> Void

    @Environment(CalendarStore.self) private var calendarStore
    @Query private var pages: [DayPage]

    init(week: [Date], start: Date, end: Date, onOpenDay: @escaping (Date) -> Void) {
        self.week = week
        self.onOpenDay = onOpenDay
        _pages = Query(filter: #Predicate<DayPage> { $0.day >= start && $0.day < end })
    }

    var body: some View {
        let pagesByDay = Dictionary(pages.map { ($0.day, $0) }, uniquingKeysWith: { first, _ in first })

        VStack(spacing: 0) {
            ForEach(week, id: \.self) { day in
                WeekDayRow(day: day, page: pagesByDay[day], events: calendarStore.events(on: day))
                    .contentShape(Rectangle())
                    .onTapGesture { onOpenDay(day) }
                Rectangle().fill(Theme.ink.opacity(0.12)).frame(height: 0.5)
            }
        }
    }
}

private struct WeekDayRow: View {
    let day: Date
    let page: DayPage?
    let events: [EKEvent]

    var body: some View {
        let isToday = Calendar.current.isDateInToday(day)
        let items = Array((page?.sortedItems ?? []).prefix(3))

        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Text(day.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .serif))
                    .tracking(1)
                Text(day.formatted(.dateTime.day()))
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                if let mood = page?.mood {
                    Text(mood).font(.system(size: 12))
                }
            }
            .foregroundStyle(isToday ? Theme.coverRed : Theme.ink)
            .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(events, id: \.calendarItemIdentifier) { event in
                    EventLine(event: event)
                }
                ForEach(items) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.symbol).font(.system(size: 13, weight: .bold)).frame(width: 12)
                        Text(item.text).font(.system(size: 13, design: .serif)).lineLimit(1)
                    }
                    .foregroundStyle(Theme.ink.opacity(item.isSettled ? 0.45 : 0.85))
                }
                if events.isEmpty && items.isEmpty {
                    Text(" ").font(.system(size: 13))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
        }
        .padding(.vertical, 10)
        .background(isToday ? NotebookSection.today.tabColor.opacity(0.18) : .clear)
    }
}
