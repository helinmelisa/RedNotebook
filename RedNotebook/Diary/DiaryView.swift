import SwiftData
import SwiftUI

/// The Diary tab: a blank dotted page for each day, bullet journal style, to write on, stick things on and
/// draw on. Turn the pages with a finger; every entry so far is a tap away, searchable.
struct DiaryView: View {
    @Binding var day: Date

    @Environment(\.modelContext) private var context
    @State private var tools = PageTools()
    @State private var showingEntries = false

    var body: some View {
        CurlingPages(day: $day, isLocked: tools.isBusy) { pageDay in
            DiaryPage(page: DayPage.page(for: pageDay, in: context), day: $day, tools: tools,
                      onShowEntries: { showingEntries = true })
                .modelContext(context)
                .tint(Theme.accent)
        }
        .pageTools(tools, day: day, onDiary: true)
        .sheet(isPresented: $showingEntries) {
            DiaryEntries { picked in
                showingEntries = false
                day = picked
            }
        }
    }
}

/// One day's diary page: the date at the top, then dots all the way down.
private struct DiaryPage: View {
    @Bindable var page: DayPage
    @Binding var day: Date
    let tools: PageTools
    var onShowEntries: () -> Void

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    TextField("Dear diary…", text: $page.diaryText, axis: .vertical)
                        .font(Theme.handwriting(size: 22))
                        .lineSpacing(2)
                        .foregroundStyle(Theme.ink)
                }
                .padding(.top, 20)
                .padding(.bottom, 120)
                // The whole page is there to stick and draw on, even before anything's written
                .frame(minHeight: geo.size.height, alignment: .top)
                .overlay {
                    DrawingCanvas(data: $page.diaryDrawing,
                                  isActive: tools.isDrawing && Calendar.current.isDate(page.day, inSameDayAs: day))
                }
                .overlay {
                    StickerLayer(page: page, onDiary: true, selection: Bindable(tools).selectedSticker)
                        .allowsHitTesting(!tools.isDrawing)
                }
                .notebookPage(dotted: true)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .scrollDisabled(tools.isBusy)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(page.day.formatted(.dateTime.day()))
                    .font(Theme.display(34))
                    .foregroundStyle(NotebookSection.diary.tabColor.mix(with: Theme.ink, by: 0.35))
                VStack(alignment: .leading, spacing: 1) {
                    Text(page.day.formatted(.dateTime.weekday(.wide)).uppercased())
                        .font(Theme.eyebrow)
                        .tracking(2.5)
                        .foregroundStyle(Theme.ink)
                    Text(page.day.formatted(.dateTime.month(.wide).year()))
                        .font(Theme.text(14))
                        .foregroundStyle(Theme.inkSecondary)
                }
                Spacer(minLength: 0)
                if !Calendar.current.isDateInToday(page.day) {
                    Button("Today") { day = .now }
                        .font(Theme.serif(11, .semibold))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(Capsule().stroke(Theme.accent.opacity(0.5), lineWidth: 1))
                }
                Button(action: onShowEntries) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.inkSecondary)
                        .frame(width: 30, height: 28)
                        .background(Circle().fill(Theme.ink.opacity(0.05)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("All diary entries")
            }
            Rule(color: NotebookSection.diary.tabColor)
        }
    }
}

/// Every diary entry, newest first, grouped by month and searchable. Tap one to turn to its page.
private struct DiaryEntries: View {
    var onOpenDay: (Date) -> Void

    @Query(filter: #Predicate<DayPage> { !$0.diaryText.isEmpty }, sort: \DayPage.day, order: .reverse)
    private var pages: [DayPage]

    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    var body: some View {
        let matches = filtered
        let months = Dictionary(grouping: matches) {
            Calendar.current.dateInterval(of: .month, for: $0.day)?.start ?? $0.day
        }

        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    searchField

                    if matches.isEmpty {
                        Text(pages.isEmpty ? "No diary entries yet." : "No entries match “\(search)”.")
                            .font(Theme.serif(15).italic())
                            .foregroundStyle(Theme.ink.opacity(0.5))
                    }

                    ForEach(months.keys.sorted(by: >), id: \.self) { month in
                        Text(month.formatted(.dateTime.month(.wide).year()).uppercased())
                            .font(Theme.serif(11, .semibold))
                            .tracking(2)
                            .foregroundStyle(Theme.accent)
                            .padding(.top, 6)

                        ForEach(months[month] ?? []) { page in
                            DiaryEntry(page: page, highlight: search)
                                .contentShape(Rectangle())
                                .onTapGesture { onOpenDay(page.day) }
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(DotPaper().ignoresSafeArea())
            .navigationTitle(pages.count == 1 ? "1 entry" : "\(pages.count) entries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.font(Theme.serif(16, .semibold))
                }
            }
        }
    }

    private var filtered: [DayPage] {
        let query = search.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return pages }
        return pages.filter { $0.diaryText.localizedStandardContains(query) }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.ink.opacity(0.4))
            TextField("Search your diary", text: $search)
                .font(Theme.serif(15))
                .submitLabel(.search)
            if !search.isEmpty {
                Button { search = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.ink.opacity(0.35))
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Theme.ink.opacity(0.05)))
    }
}

private struct DiaryEntry: View {
    let page: DayPage
    let highlight: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(page.day.formatted(.dateTime.day()))
                    .font(Theme.serif(22, .semibold))
                Text(page.day.formatted(.dateTime.weekday(.wide)))
                    .font(Theme.serif(13))
                    .foregroundStyle(Theme.ink.opacity(0.55))
                Spacer()
                if let weather = page.weather {
                    Image(systemName: weather).font(.system(size: 13)).foregroundStyle(Theme.ink.opacity(0.5))
                }
                if let mood = page.mood {
                    MoodFace(mood: mood).frame(width: 20, height: 20)
                }
            }
            .foregroundStyle(Theme.ink)

            Text(highlighted)
                .font(Theme.handwriting(size: 19))
                .foregroundStyle(Theme.ink.opacity(0.85))
                .lineLimit(5)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 6).fill(Theme.paper.opacity(0.7)))
        .overlay(alignment: .leading) {
            Rectangle().fill(NotebookSection.diary.tabColor).frame(width: 3)
        }
        .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
    }

    /// The diary text with search matches marked like a highlighter pen.
    private var highlighted: AttributedString {
        var text = AttributedString(page.diaryText)
        let query = highlight.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return text }
        var searchRange = text.startIndex..<text.endIndex
        while let match = text[searchRange].range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) {
            text[match].backgroundColor = NotebookSection.today.tabColor.opacity(0.6)
            searchRange = match.upperBound..<text.endIndex
        }
        return text
    }
}
