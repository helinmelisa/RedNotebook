import SwiftUI

/// Hobonichi-style date block: a big red day number with the weekday, month and year beside it,
/// arrows to flip days, and the mood/weather row.
struct DayHeader: View {
    @Bindable var page: DayPage
    @Binding var day: Date

    private static let moods = Moods.all
    private static let weathers = ["sun.max", "cloud.sun", "cloud", "cloud.rain", "cloud.bolt", "snowflake", "wind"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Text(page.day.formatted(.dateTime.day()))
                    .font(Theme.serif(54, .bold))
                    .monospacedDigit()
                    .foregroundStyle(Theme.accent)
                    .frame(minWidth: 62, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(page.day.formatted(.dateTime.weekday(.wide)).uppercased())
                        .font(Theme.eyebrow)
                        .tracking(2.5)
                        .foregroundStyle(Theme.ink)
                    Text(page.day.formatted(.dateTime.month(.wide).year()))
                        .font(Theme.text(17))
                        .foregroundStyle(Theme.inkSecondary)
                    HStack(spacing: 8) {
                        Text(dayOfYearLabel)
                            .foregroundStyle(Theme.inkTertiary)
                        if !Calendar.current.isDateInToday(page.day) {
                            Button("Today") { flip(to: .now) }
                                .font(Theme.serif(11, .semibold))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 1)
                                .background(Capsule().stroke(Theme.accent.opacity(0.5), lineWidth: 1))
                                .accessibilityLabel("Back to today")
                        }
                    }
                    .font(Theme.text(11))
                }

                Spacer(minLength: 0)
                dayArrows
            }

            Rule(color: NotebookSection.today.tabColor)

            moodAndWeather
        }
    }

    private var dayArrows: some View {
        VStack(spacing: 6) {
            arrow("chevron.up", label: "Previous day") { flip(by: -1) }
            arrow("chevron.down", label: "Next day") { flip(by: 1) }
        }
    }

    private func arrow(_ systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.inkSecondary)
                .frame(width: 28, height: 26)
                .background(Circle().fill(Theme.ink.opacity(0.05)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var moodAndWeather: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                ForEach(Self.moods, id: \.self) { mood in
                    let selected = page.mood == mood
                    Button { toggle(\.mood, mood) } label: {
                        Text(mood)
                            .font(.system(size: 19))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(selected ? NotebookSection.today.tabColor.opacity(0.55) : .clear))
                            .overlay(Circle().stroke(selected ? NotebookSection.today.tabColor : .clear, lineWidth: 1.5))
                            .scaleEffect(selected ? 1.08 : 1)
                            .opacity(page.mood == nil || selected ? 1 : 0.35)
                            .saturation(page.mood == nil || selected ? 1 : 0.3)
                    }
                    .accessibilityLabel("Mood \(mood)")
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            HStack(spacing: 2) {
                ForEach(Self.weathers, id: \.self) { weather in
                    let selected = page.weather == weather
                    Button { toggle(\.weather, weather) } label: {
                        // Selected weather turns colourful; snowflake and wind have no filled variant
                        Image(systemName: selected && !["snowflake", "wind"].contains(weather) ? "\(weather).fill" : weather)
                            .symbolRenderingMode(selected ? .multicolor : .monochrome)
                            .font(.system(size: 15))
                            .frame(width: 32, height: 26)
                            .foregroundStyle(selected ? Theme.ink : Theme.inkTertiary)
                            .background(Capsule().fill(selected ? NotebookSection.calendar.tabColor.opacity(0.35) : .clear))
                    }
                    .accessibilityLabel("Weather \(weather)")
                    .accessibilityAddTraits(selected ? .isSelected : [])
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
