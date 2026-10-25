import SwiftData
import SwiftUI

/// The Diary tab: flip back through every diary entry, newest first, grouped by month and searchable.
struct DiaryView: View {
    var onOpenDay: (Date) -> Void

    @Query(filter: #Predicate<DayPage> { !$0.diaryText.isEmpty }, sort: \DayPage.day, order: .reverse)
    private var pages: [DayPage]

    @State private var search = ""

    var body: some View {
        let matches = filtered
        let months = Dictionary(grouping: matches) {
            Calendar.current.dateInterval(of: .month, for: $0.day)?.start ?? $0.day
        }

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header
                searchField

                if matches.isEmpty {
                    Text(pages.isEmpty ? "No diary entries yet. Write one on the Today page." : "No entries match “\(search)”.")
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
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private var filtered: [DayPage] {
        let query = search.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return pages }
        return pages.filter { $0.diaryText.localizedStandardContains(query) }
    }

    private var header: some View {
        PageTitle(eyebrow: pages.count == 1 ? "1 entry" : "\(pages.count) entries", title: "Diary",
                  color: NotebookSection.diary.tabColor)
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
                    Text(mood).font(.system(size: 16))
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
