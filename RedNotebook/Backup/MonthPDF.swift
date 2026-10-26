import SwiftData
import SwiftUI

/// A month of pages as a printable A5 PDF: a title page, then one page per day that has something on it.
enum MonthPDF {
    /// A5 in points.
    static let pageSize = CGSize(width: 420, height: 595)

    @MainActor
    static func make(month: Date, from context: ModelContext) -> Data? {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return nil }
        let start = interval.start, end = interval.end
        let descriptor = FetchDescriptor<DayPage>(predicate: #Predicate { $0.day >= start && $0.day < end },
                                                  sortBy: [SortDescriptor(\.day)])
        let pages = ((try? context.fetch(descriptor)) ?? []).filter { !$0.isEmpty }
        let title = AnyView(MonthTitlePage(month: interval.start, pages: pages))
        let views = [title] + pages.map { AnyView(PrintablePage(page: $0)) }

        let data = NSMutableData()
        var box = CGRect(origin: .zero, size: pageSize)
        guard let consumer = CGDataConsumer(data: data as CFMutableData),
              let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else { return nil }
        for view in views {
            let renderer = ImageRenderer(content: view.frame(width: pageSize.width, height: pageSize.height))
            renderer.proposedSize = ProposedViewSize(pageSize)
            renderer.render { _, draw in
                pdf.beginPDFPage(nil)
                draw(pdf)
                pdf.endPDFPage()
            }
        }
        pdf.closePDF()
        return data as Data
    }

    static func fileName(for month: Date) -> String {
        "helin's " + month.formatted(.dateTime.month(.wide).year())
    }
}

/// The first page: the month, the cover colour and a strip of the month's moods.
private struct MonthTitlePage: View {
    let month: Date
    let pages: [DayPage]

    var body: some View {
        let cover = Theme.cover
        let calendar = Calendar.current
        let days = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let moods = Dictionary(pages.compactMap { page in page.mood.map { (calendar.component(.day, from: page.day), $0) } },
                               uniquingKeysWith: { first, _ in first })

        ZStack {
            LinearGradient(colors: [cover.light, cover.base, cover.dark], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 14) {
                Spacer()
                Text(UserDefaults.standard.string(forKey: CoverFace.titleKey) ?? CoverFace.defaultTitle)
                    .font(Theme.serif(40, .semibold))
                    .tracking(10)
                Rectangle().frame(width: 60, height: 1.5)
                Text(month.formatted(.dateTime.month(.wide).year()))
                    .font(Theme.serif(20).italic())
                Spacer()
                // A row of mood pixels, one per day
                HStack(spacing: 3) {
                    ForEach(1...days, id: \.self) { day in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(moods[day].map(Moods.color) ?? .white.opacity(0.25))
                            .frame(width: 8, height: 8)
                    }
                }
                Text("\(pages.count) pages")
                    .font(Theme.serif(11))
                    .padding(.bottom, 40)
            }
            .foregroundStyle(cover == .pink ? Theme.ink.opacity(0.75) : .white.opacity(0.92))
        }
    }
}

/// One day, laid out for paper: everything on the page, read-only.
private struct PrintablePage: View {
    let page: DayPage

    var body: some View {
        ZStack(alignment: .topLeading) {
            GridPaper()
            VStack(alignment: .leading, spacing: 14) {
                header
                if !page.habitsDone.isEmpty { habits }
                if !page.sortedItems.isEmpty { section("Tasks & events") { tasks } }
                if !page.diaryText.isEmpty {
                    section("Diary") {
                        Text(page.diaryText).font(Theme.handwriting(size: 17)).lineSpacing(1)
                    }
                }
                if !page.promptAnswer.isEmpty {
                    section("Question of the day") {
                        Text(DailyPrompt.question(for: page.day)).font(Theme.serif(11).italic()).foregroundStyle(Theme.inkSecondary)
                        Text(page.promptAnswer).font(Theme.handwriting(size: 17))
                    }
                }
                if !page.sortedMeals.isEmpty { section("What I ate") { meals } }
                if !page.sortedNotes.isEmpty { notes }
                Spacer(minLength: 0)
                stickers
            }
            .foregroundStyle(Theme.ink)
            .padding(28)
        }
        .clipped()
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(page.day.formatted(.dateTime.day()))
                .font(Theme.serif(34, .semibold))
                .foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(page.day.formatted(.dateTime.weekday(.wide)).uppercased())
                    .font(Theme.eyebrow).tracking(2)
                Text(page.day.formatted(.dateTime.month(.wide).year()))
                    .font(Theme.serif(13)).foregroundStyle(Theme.inkSecondary)
            }
            Spacer()
            if let weather = page.weather {
                Image(systemName: weather).font(.system(size: 18)).foregroundStyle(Theme.inkSecondary)
            }
            if let mood = page.mood {
                MoodFace(mood: mood).frame(width: 26, height: 26)
            }
        }
    }

    private var habits: some View {
        let all = Habit.list(from: UserDefaults.standard.string(forKey: Habit.storageKey) ?? "")
        return HStack(spacing: 10) {
            ForEach(all.filter { page.habitsDone.contains($0.id) }) { habit in
                Text("\(habit.emoji) \(habit.name)").font(Theme.serif(10))
            }
        }
        .foregroundStyle(Theme.inkSecondary)
    }

    private var tasks: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(page.sortedItems) { item in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(mark(for: item)).font(Theme.serif(13, .semibold)).frame(width: 14)
                    Text(item.text)
                        .font(Theme.serif(13))
                        .strikethrough(item.state == .cancelled)
                        .foregroundStyle(item.isSettled ? Theme.inkTertiary : Theme.ink)
                }
            }
        }
    }

    private func mark(for item: BulletItem) -> String {
        guard item.kind == .task else { return item.symbol }
        switch item.state {
        case .done: return "☑"
        case .migrated: return ">"
        case .cancelled, .open: return "☐"
        }
    }

    private var meals: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(page.sortedMeals) { meal in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(meal.time.formatted(date: .omitted, time: .shortened))
                        .font(Theme.serif(10)).foregroundStyle(Theme.inkTertiary).frame(width: 44, alignment: .leading)
                    Text(meal.text).font(Theme.serif(12))
                }
            }
        }
    }

    private var notes: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(page.sortedNotes.prefix(4)) { note in
                Text(note.text)
                    .font(Theme.handwriting(size: 14))
                    .padding(8)
                    .frame(width: 80, height: 70, alignment: .topLeading)
                    .background(Theme.stickyColors[note.colorIndex % Theme.stickyColors.count])
            }
        }
    }

    /// The page's stickers and photos, in a row along the bottom.
    private var stickers: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(page.sortedStickers.prefix(6)) { sticker in
                if let choice = sticker.choice {
                    StickerContent(choice: choice, text: sticker.text)
                        .scaleEffect(0.6)
                        .frame(width: 60, height: 80)
                }
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased()).font(Theme.eyebrow).tracking(1.5).foregroundStyle(Theme.inkTertiary)
            content()
        }
    }
}
