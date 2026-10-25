import SwiftData
import SwiftUI

/// Year in pixels: one small square per day, coloured by that day's mood. Tap a square to open the day.
struct YearView: View {
    @Binding var selectedDay: Date
    var onOpenDay: (Date) -> Void

    @State private var year = Calendar.current.component(.year, from: .now)

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

            PixelGrid(year: year, onOpenDay: onOpenDay)
                .id(year)

            legend
        }
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
    var onOpenDay: (Date) -> Void

    @Query private var pages: [DayPage]

    init(year: Int, onOpenDay: @escaping (Date) -> Void) {
        self.year = year
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
                            Pixel(date: date, page: pagesByDay[date])
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

    var body: some View {
        let isToday = Calendar.current.isDateInToday(date)
        let fill: Color = if let mood = page?.mood {
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
