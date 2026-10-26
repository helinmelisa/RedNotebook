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
                HankoDate(number: page.day.formatted(.dateTime.day()))

                VStack(alignment: .leading, spacing: 2) {
                    Text(page.day.formatted(.dateTime.weekday(.wide)).uppercased())
                        .font(Theme.eyebrow)
                        .tracking(2.5)
                        .foregroundStyle(Theme.ink)
                    Text(page.day.formatted(.dateTime.month(.wide).year()))
                        .font(Theme.text(17))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .foregroundStyle(Theme.inkSecondary)
                    Text(dayOfYearLabel)
                        .font(Theme.text(11))
                        .foregroundStyle(Theme.inkTertiary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        weatherChip
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
                    .fixedSize()
                    .padding(.top, 3)
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
                        MoodFace(mood: mood)
                            .frame(width: 24, height: 24)
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
        }
        .buttonStyle(.plain)
    }

    /// Weather as one small chip; tap to choose. Saves a whole row on the page.
    private var weatherChip: some View {
        Menu {
            ForEach(Self.weathers, id: \.self) { weather in
                Button { toggle(\.weather, weather) } label: {
                    Label(Self.weatherName(weather), systemImage: weather)
                }
            }
        } label: {
            HStack(spacing: 3) {
                Image(systemName: page.weather.map { ["snowflake", "wind"].contains($0) ? $0 : "\($0).fill" } ?? "cloud.sun")
                    .symbolRenderingMode(page.weather == nil ? .monochrome : .multicolor)
                if page.weather == nil { Text("weather") }
            }
            .font(Theme.text(11))
            .foregroundStyle(Theme.inkTertiary)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Capsule().stroke(Theme.hairline, lineWidth: 1))
        }
        .accessibilityLabel(page.weather.map { "Weather: \(Self.weatherName($0))" } ?? "Add weather")
    }

    private static func weatherName(_ symbol: String) -> String {
        switch symbol {
        case "sun.max": "Sunny"
        case "cloud.sun": "Partly cloudy"
        case "cloud": "Cloudy"
        case "cloud.rain": "Rainy"
        case "cloud.bolt": "Stormy"
        case "snowflake": "Snow"
        case "wind": "Windy"
        default: symbol
        }
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

/// The day number as a red hanko seal: a double ring, slightly tilted, with ink that didn't take everywhere.
private struct HankoDate: View {
    let number: String

    var body: some View {
        ZStack {
            Circle().stroke(Theme.accent, lineWidth: 2.6)
            Circle().stroke(Theme.accent, lineWidth: 0.9).padding(4.5)
            Text(number)
                .font(Theme.serif(34, .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.accent)
        }
        .frame(width: 70, height: 70)
        .mask(StampInk())
        .rotationEffect(.degrees(-7))
        .accessibilityElement(children: .combine)
    }
}

/// Mask with small gaps and lighter patches, like ink from a rubber stamp.
private struct StampInk: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
            var rng = SeededRandom(seed: 21)
            context.blendMode = .destinationOut
            for _ in 0..<70 {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let r = Double.random(in: 0.5...2.2, using: &rng)
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r * 0.8)),
                             with: .color(.black.opacity(Double.random(in: 0.4...0.9, using: &rng))))
            }
            // One side pressed a little lighter
            context.fill(Path(CGRect(x: size.width * 0.62, y: 0, width: size.width * 0.38, height: size.height)),
                         with: .color(.black.opacity(0.12)))
        }
    }
}
