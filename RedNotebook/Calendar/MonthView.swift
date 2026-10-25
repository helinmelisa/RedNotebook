import SwiftUI
import SwiftData

/// Month title with arrows, the day grid, and the agenda for the selected day.
struct MonthView: View {
    @Binding var selectedDay: Date
    var onOpenDay: (Date) -> Void

    @State private var month = Date.now

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(month.formatted(.dateTime.year()))
                        .font(Theme.serif(11, .semibold))
                        .tracking(2)
                        .foregroundStyle(Theme.accent)
                    Text(month.formatted(.dateTime.month(.wide)))
                        .font(Theme.serif(28, .semibold))
                        .foregroundStyle(Theme.ink)
                }
                Spacer()
                HStack(spacing: 14) {
                    Button { flip(by: -1) } label: { Image(systemName: "chevron.left") }
                        .accessibilityLabel("Previous month")
                    Button { flip(by: 1) } label: { Image(systemName: "chevron.right") }
                        .accessibilityLabel("Next month")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.ink.opacity(0.5))
            }

            MonthGrid(month: month, selectedDay: $selectedDay, onOpenDay: onOpenDay)
                .id(month)

            DayAgenda(day: selectedDay, onOpenDay: onOpenDay)
        }
        .onAppear { month = selectedDay }
    }

    private func flip(by months: Int) {
        guard let target = Calendar.current.date(byAdding: .month, value: months, to: month) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.easeInOut(duration: 0.25)) { month = target }
    }
}

private struct MonthGrid: View {
    let month: Date
    @Binding var selectedDay: Date
    var onOpenDay: (Date) -> Void

    @Environment(CalendarStore.self) private var calendarStore
    @Query private var pages: [DayPage]

    init(month: Date, selectedDay: Binding<Date>, onOpenDay: @escaping (Date) -> Void) {
        self.month = month
        self._selectedDay = selectedDay
        self.onOpenDay = onOpenDay
        let interval = Calendar.current.dateInterval(of: .month, for: month)!
        let start = interval.start, end = interval.end
        _pages = Query(filter: #Predicate<DayPage> { $0.day >= start && $0.day < end })
    }

    var body: some View {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: month)!
        let events = calendarStore.events(from: interval.start, to: interval.end)
        let pagesByDay = Dictionary(pages.map { ($0.day, $0) }, uniquingKeysWith: { first, _ in first })
        let cells = calendar.monthGrid(for: month)

        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 7), spacing: 3) {
            ForEach(Array(calendar.orderedWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(Theme.serif(11, .semibold))
                    .foregroundStyle(Theme.ink.opacity(0.45))
                    .padding(.bottom, 4)
            }

            ForEach(cells.indices, id: \.self) { index in
                if let day = cells[index] {
                    let end = calendar.date(byAdding: .day, value: 1, to: day)!
                    let dayEvents = events.filter { $0.startDate < end && $0.endDate > day }
                    let holiday = PortugueseHolidays.holiday(on: day)
                    DayCell(day: day,
                            page: pagesByDay[day],
                            isHoliday: holiday != nil,
                            eventColors: (holiday.map { _ in [PortugueseHolidays.color] } ?? [])
                                + dayEvents.prefix(holiday == nil ? 3 : 2).map(\.color),
                            isSelected: calendar.isDate(day, inSameDayAs: selectedDay))
                        .onTapGesture { select(day) }
                } else {
                    Color.clear.frame(height: 56)
                }
            }
        }
    }

    /// First tap selects a day, a second tap opens its page.
    private func select(_ day: Date) {
        if Calendar.current.isDate(day, inSameDayAs: selectedDay) {
            onOpenDay(day)
        } else {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.snappy) { selectedDay = day }
        }
    }
}

private struct DayCell: View {
    let day: Date
    let page: DayPage?
    let isHoliday: Bool
    let eventColors: [Color]
    let isSelected: Bool

    var body: some View {
        let isToday = Calendar.current.isDateInToday(day)
        let mood = page?.mood

        // A little planner square: number and mood on top, the day's top sticker in the middle, events below
        VStack(spacing: 1) {
            HStack(alignment: .top, spacing: 0) {
                Text(day.formatted(.dateTime.day()))
                    .font(Theme.serif(12, isToday ? .bold : .medium))
                    .foregroundStyle(isToday ? Theme.paper : isHoliday ? PortugueseHolidays.color : Theme.ink)
                    .frame(width: 20, height: 20)
                    .background { if isToday { Circle().fill(Theme.accent) } }
                Spacer(minLength: 0)
                if let mood {
                    MoodFace(mood: mood).frame(width: 12, height: 12)
                }
            }

            Group {
                if let top = page?.sortedStickers.last, let choice = top.choice {
                    StickerContent(choice: choice, text: top.text)
                        .scaleEffect(0.24)
                        .frame(width: 30, height: 20)
                } else if let page, !page.isEmpty {
                    Circle().fill(Theme.accent.opacity(0.5)).frame(width: 4, height: 4)
                } else {
                    Color.clear
                }
            }
            .frame(height: 20)
            .allowsHitTesting(false)

            HStack(spacing: 2) {
                ForEach(eventColors.indices, id: \.self) { index in
                    Capsule().fill(eventColors[index]).frame(width: 6, height: 2.5)
                }
            }
            .frame(height: 3)
        }
        .padding(3)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(mood.map { Moods.color($0).opacity(0.3) } ?? Theme.ink.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isSelected ? Theme.accent : .clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
