import AppIntents
import SwiftUI
import WidgetKit

@main
struct NotebookWidgets: WidgetBundle {
    init() {
        Theme.registerFonts()
    }

    var body: some Widget {
        NotebookWidget()
    }
}

// MARK: - Configuration

/// The cover colour, picked when editing the widget (the widget can't read the app's settings).
enum WidgetCover: String, AppEnum {
    case red, teal, navy, pink, matcha

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Cover colour"
    static let caseDisplayRepresentations: [WidgetCover: DisplayRepresentation] = [
        .red: "Wine red", .teal: "Teal", .navy: "Navy", .pink: "Pastel pink", .matcha: "Matcha",
    ]

    var color: CoverColor { CoverColor(rawValue: rawValue) ?? .red }
}

struct NotebookWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "helin's"
    static let description = IntentDescription("Today's date and the Portuguese word of the day.")

    @Parameter(title: "Cover colour", default: .red)
    var cover: WidgetCover
}

// MARK: - Timeline

struct NotebookEntry: TimelineEntry {
    let date: Date
    let cover: CoverColor
}

struct NotebookProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> NotebookEntry {
        NotebookEntry(date: .now, cover: .red)
    }

    func snapshot(for configuration: NotebookWidgetIntent, in context: Context) async -> NotebookEntry {
        NotebookEntry(date: .now, cover: configuration.cover.color)
    }

    /// One entry now and one at midnight, when the date and the word change.
    func timeline(for configuration: NotebookWidgetIntent, in context: Context) async -> Timeline<NotebookEntry> {
        let midnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
        let entries = [NotebookEntry(date: .now, cover: configuration.cover.color),
                       NotebookEntry(date: midnight, cover: configuration.cover.color)]
        return Timeline(entries: entries, policy: .after(midnight))
    }
}

// MARK: - Widget

struct NotebookWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "NotebookWidget", intent: NotebookWidgetIntent.self, provider: NotebookProvider()) { entry in
            NotebookWidgetView(entry: entry)
                .containerBackground(for: .widget) { GridPaper() }
        }
        .configurationDisplayName("helin's")
        .description("Today's date as a hanko stamp, and the Portuguese word of the day.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct NotebookWidgetView: View {
    let entry: NotebookEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let word = PortugueseWord.of(entry.date)

        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)))
                    .font(.headline)
                Text("🇵🇹 \(word.word)")
                    .font(.body)
                Text(word.meaning)
                    .font(.caption)
                    .lineLimit(1)
            }
        case .systemMedium:
            HStack(alignment: .top, spacing: 14) {
                dateBlock
                    .frame(width: 104, alignment: .leading)
                Rectangle().fill(Theme.hairline).frame(width: 0.5)
                wordBlock(word, showSentence: true)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                dateBlock
                Spacer(minLength: 0)
                wordBlock(word, showSentence: false)
            }
        }
    }

    private var dateBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Stamp(number: entry.date.formatted(.dateTime.day()), color: entry.cover.accent)
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.date.formatted(.dateTime.weekday(.wide)).uppercased())
                    .font(Theme.serif(10, .semibold))
                    .tracking(1.5)
                    .foregroundStyle(Theme.ink)
                Text(entry.date.formatted(.dateTime.month(.wide)))
                    .font(Theme.serif(12))
                    .foregroundStyle(Theme.inkSecondary)
            }
        }
    }

    private func wordBlock(_ word: PortugueseWord, showSentence: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("PALAVRA DO DIA")
                .font(Theme.serif(8, .semibold))
                .tracking(1.2)
                .foregroundStyle(PortugueseHolidays.color)
            Text(word.word)
                .font(Theme.serif(showSentence ? 20 : 16, .semibold))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(word.meaning)
                .font(Theme.serif(11).italic())
                .foregroundStyle(Theme.inkSecondary)
                .lineLimit(2)
            if showSentence {
                Spacer(minLength: 2)
                Text(word.sentence)
                    .font(Theme.handwriting(size: 17))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                Text(word.translation)
                    .font(Theme.serif(10))
                    .foregroundStyle(Theme.inkTertiary)
                    .lineLimit(1)
            }
        }
    }
}

/// The day number as a red hanko seal, like at the top of each notebook page.
private struct Stamp: View {
    let number: String
    let color: Color

    var body: some View {
        ZStack {
            Circle().stroke(color, lineWidth: 2)
            Circle().stroke(color, lineWidth: 0.7).padding(3.5)
            Text(number)
                .font(Theme.serif(24, .bold))
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .frame(width: 50, height: 50)
        .rotationEffect(.degrees(-7))
    }
}

#Preview(as: .systemMedium) {
    NotebookWidget()
} timeline: {
    NotebookEntry(date: .now, cover: .red)
}
