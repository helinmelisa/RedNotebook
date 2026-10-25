import SwiftUI

/// Date at the top of the page, with arrows to flip days and a mood/weather row.
struct DayHeader: View {
    @Bindable var page: DayPage
    @Binding var day: Date

    private static let moods = ["🥰", "😊", "🙂", "😐", "😔", "😢", "😡", "😴"]
    private static let weathers = ["sun.max", "cloud.sun", "cloud", "cloud.rain", "cloud.bolt", "snowflake", "wind"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(page.day.formatted(.dateTime.weekday(.wide)).uppercased())
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .tracking(2)
                        .foregroundStyle(Theme.coverRed)
                    Text(page.day.formatted(.dateTime.day().month(.wide)))
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                }
                Spacer()
                dayArrows
            }

            HStack(spacing: 10) {
                Text(dayOfYearLabel)
                if !Calendar.current.isDateInToday(page.day) {
                    Button("Back to today") { flip(to: .now) }
                        .foregroundStyle(Theme.coverRed)
                }
            }
            .font(.system(size: 11, design: .serif))
            .foregroundStyle(Theme.ink.opacity(0.5))

            Rectangle().fill(NotebookSection.today.tabColor).frame(height: 2)

            moodAndWeather
        }
    }

    private var dayArrows: some View {
        HStack(spacing: 14) {
            Button { flip(by: -1) } label: { Image(systemName: "chevron.left") }
                .accessibilityLabel("Previous day")
            Button { flip(by: 1) } label: { Image(systemName: "chevron.right") }
                .accessibilityLabel("Next day")
        }
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(Theme.ink.opacity(0.5))
    }

    private var moodAndWeather: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(Self.moods, id: \.self) { mood in
                    Button { toggle(\.mood, mood) } label: {
                        Text(mood)
                            .font(.system(size: 18))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(page.mood == mood ? NotebookSection.today.tabColor.opacity(0.6) : .clear))
                            .opacity(page.mood == nil || page.mood == mood ? 1 : 0.4)
                    }
                    .accessibilityLabel("Mood \(mood)")
                }
            }
            HStack(spacing: 4) {
                ForEach(Self.weathers, id: \.self) { weather in
                    Button { toggle(\.weather, weather) } label: {
                        Image(systemName: weather)
                            .font(.system(size: 14))
                            .frame(width: 30, height: 26)
                            .foregroundStyle(Theme.ink.opacity(page.weather == weather ? 0.9 : 0.35))
                            .background(Capsule().fill(page.weather == weather ? NotebookSection.calendar.tabColor.opacity(0.5) : .clear))
                    }
                    .accessibilityLabel("Weather \(weather)")
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var dayOfYearLabel: String {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: page.day) ?? 1
        let daysInYear = calendar.range(of: .day, in: .year, for: page.day)?.count ?? 365
        return "Day \(dayOfYear) of \(daysInYear)"
    }

    /// Tapping the selected mood/weather again clears it.
    private func toggle(_ keyPath: ReferenceWritableKeyPath<DayPage, String?>, _ value: String) {
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.snappy) {
            page[keyPath: keyPath] = page[keyPath: keyPath] == value ? nil : value
        }
    }

    private func flip(by days: Int) {
        guard let target = Calendar.current.date(byAdding: .day, value: days, to: day) else { return }
        flip(to: target)
    }

    private func flip(to target: Date) {
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.easeInOut(duration: 0.25)) { day = target }
    }
}
