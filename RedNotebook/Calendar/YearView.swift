import SwiftData
import SwiftUI

/// Year in pixels: one small square per day, coloured by that day's mood. Tap a square to open the day.
struct YearView: View {
    @Binding var selectedDay: Date
    var onOpenDay: (Date) -> Void

    @State private var year = Calendar.current.component(.year, from: .now)
    /// nil colours the pixels by mood; otherwise by whether this habit was done.
    @State private var habitID: String?
    @AppStorage(Habit.storageKey) private var habitsRaw = ""

    private var habit: Habit? { Habit.list(from: habitsRaw).first { $0.id == habitID } }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YEAR IN PIXELS")
                        .font(Theme.eyebrow)
                        .tracking(2)
                        .foregroundStyle(Theme.accent)
                    Text(String(year))
                        .font(Theme.display())
                        .foregroundStyle(Theme.ink)
                }
                Spacer()
                HStack(spacing: 14) {
                    Button { year -= 1 } label: { Image(systemName: "chevron.left") }
                        .accessibilityLabel("Previous year")
                    Button { year += 1 } label: { Image(systemName: "chevron.right") }
                        .accessibilityLabel("Next year")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.inkTertiary)
            }

            colourByPicker

            PixelGrid(year: year, habit: habit, onOpenDay: onOpenDay)
                .id(year)

            if let habit {
                HabitLegend(year: year, habit: habit)
            } else {
                legend
            }
        }
    }

    /// Mood, or one of the habits, as chips.
    private var colourByPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                chip("Mood", selected: habit == nil) { habitID = nil }
                ForEach(Habit.list(from: habitsRaw)) { option in
                    chip("\(option.emoji) \(option.name)", selected: option.id == habit?.id) { habitID = option.id }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.snappy) { action() }
        } label: {
            Text(title)
                .font(Theme.serif(12, selected ? .semibold : .regular))
                .foregroundStyle(selected ? Theme.paper : Theme.inkSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(selected ? Theme.accent : Theme.ink.opacity(0.05)))
        }
        .buttonStyle(.plain)
    }

    private var legend: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 6, alignment: .leading)], alignment: .leading, spacing: 6) {
            ForEach(Moods.all, id: \.self) { mood in
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 2).fill(Moods.color(mood)).frame(width: 11, height: 11)
                    Text(Moods.name(mood)).font(Theme.serif(11)).foregroundStyle(Theme.inkSecondary)
                }
            }
        }
    }
}

private struct PixelGrid: View {
    let year: Int
    let habit: Habit?
    var onOpenDay: (Date) -> Void

    @Query private var pages: [DayPage]

    init(year: Int, habit: Habit?, onOpenDay: @escaping (Date) -> Void) {
        self.year = year
        self.habit = habit
        self.onOpenDay = onOpenDay
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        _pages = Query(filter: #Predicate<DayPage> { $0.day >= start && $0.day < end })
    }

    var body: some View {
        let calendar = Calendar.current
        let pagesByDay = Dictionary(pages.map { ($0.day, $0) }, uniquingKeysWith: { first, _ in first })
        let months = Array(1...12)

        // Months across, days down, like the paper "year in pixels" page in a bullet journal
        HStack(alignment: .top, spacing: 3) {
            VStack(spacing: 3) {
                Text(" ").font(Theme.serif(9))
                ForEach(1...31, id: \.self) { day in
                    Text(day % 5 == 0 || day == 1 ? "\(day)" : " ")
                        .font(Theme.serif(8))
                        .foregroundStyle(Theme.inkTertiary)
                        .frame(width: 12, height: 12)
                }
            }
            ForEach(months, id: \.self) { month in
                VStack(spacing: 3) {
                    Text(calendar.veryShortMonthSymbols[month - 1])
                        .font(Theme.serif(9, .semibold))
                        .foregroundStyle(Theme.inkSecondary)
                    ForEach(1...31, id: \.self) { dayNumber in
                        if let date = calendar.date(from: DateComponents(year: year, month: month, day: dayNumber)),
                           calendar.component(.month, from: date) == month {
                            Pixel(date: date, page: pagesByDay[date], habit: habit)
                                .onTapGesture { onOpenDay(date) }
                        } else {
                            Color.clear.frame(height: 12)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct Pixel: View {
    let date: Date
    let page: DayPage?
    let habit: Habit?

    var body: some View {
        let isToday = Calendar.current.isDateInToday(date)
        let fill: Color = if let habit {
            page?.habitsDone.contains(habit.id) == true ? Theme.accent : .clear
        } else if let mood = page?.mood {
            Moods.color(mood)
        } else if let page, !page.isEmpty {
            Theme.ink.opacity(0.15) // written, but no mood picked
        } else {
            .clear
        }

        RoundedRectangle(cornerRadius: 2)
            .fill(fill)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(isToday ? Theme.accent : Theme.hairline, lineWidth: isToday ? 1.5 : 0.5))
            .frame(height: 12)
            .contentShape(Rectangle())
            .accessibilityLabel(date.formatted(date: .long, time: .omitted) + (page?.mood.map { ", " + Moods.name($0) } ?? ""))
    }
}

/// How many days a habit was done this year, and the streak running up to today.
private struct HabitLegend: View {
    let year: Int
    let habit: Habit

    @Query private var pages: [DayPage]

    init(year: Int, habit: Habit) {
        self.year = year
        self.habit = habit
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        _pages = Query(filter: #Predicate<DayPage> { $0.day >= start && $0.day < end })
    }

    var body: some View {
        let doneDays = Set(pages.filter { $0.habitsDone.contains(habit.id) }.map(\.day))
        HStack(spacing: 16) {
            stat("\(doneDays.count)", "days done")
            stat("\(streak(in: doneDays))", "day streak")
            Spacer()
            HStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 2).fill(Theme.accent).frame(width: 11, height: 11)
                Text("\(habit.emoji) done").font(Theme.serif(11)).foregroundStyle(Theme.inkSecondary)
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value).font(Theme.serif(20, .semibold)).foregroundStyle(Theme.ink)
            Text(label).font(Theme.serif(11)).foregroundStyle(Theme.inkTertiary)
        }
    }

    /// Days in a row up to today (or yesterday, if today isn't ticked yet).
    private func streak(in days: Set<Date>) -> Int {
        let calendar = Calendar.current
        var day = calendar.startOfDay(for: .now)
        if !days.contains(day) { day = calendar.date(byAdding: .day, value: -1, to: day)! }
        var count = 0
        while days.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }
}
