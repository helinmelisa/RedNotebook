import SwiftUI
import SwiftData

/// The "1 day 1 page" spread: header, bullets, diary, sticky notes and the quote of the day.
struct TodayView: View {
    @Binding var day: Date

    @Environment(\.modelContext) private var context
    @State private var page: DayPage?

    var body: some View {
        ScrollView {
            if let page {
                DayPageContent(page: page, day: $day)
            }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .task(id: day) {
            page = DayPage.page(for: day, in: context)
        }
    }
}

private struct DayPageContent: View {
    @Bindable var page: DayPage
    @Binding var day: Date

    @Environment(\.modelContext) private var context
    @Environment(CalendarStore.self) private var calendarStore

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            DayHeader(page: page, day: $day)

            PageSection(title: "Tasks & events", color: NotebookSection.todo.tabColor) {
                // Events from the iPhone Calendar first, then the notebook's own bullets
                ForEach(calendarStore.events(on: page.day), id: \.calendarItemIdentifier) { event in
                    EventLine(event: event)
                }
                BulletList(page: page, onMigrate: migrate)
            }

            PageSection(title: "Diary", color: NotebookSection.diary.tabColor) {
                TextField("Dear diary…", text: $page.diaryText, axis: .vertical)
                    .lineLimit(6...)
                    .font(.system(size: 16, design: .serif))
                    .lineSpacing(6)
                    .foregroundStyle(Theme.ink)
            }

            PageSection(title: "Little notes", color: NotebookSection.today.tabColor) {
                QuickNotesStrip(page: page)
            }

            quote
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    private var quote: some View {
        let quote = DailyQuote.quote(for: page.day)
        return VStack(alignment: .leading, spacing: 4) {
            Rectangle().fill(Theme.ink.opacity(0.15)).frame(height: 0.5)
            Text("“\(quote.text)”")
                .font(.system(size: 12, design: .serif).italic())
            Text("— \(quote.author)")
                .font(.system(size: 10, design: .serif))
        }
        .foregroundStyle(Theme.ink.opacity(0.55))
        .padding(.top, 10)
    }

    /// Bullet journal migration: mark the task `>` and copy it to tomorrow's page.
    private func migrate(_ item: BulletItem) {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: page.day) else { return }
        item.schedule(on: tomorrow, in: context)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// A small coloured label followed by the section's content.
private struct PageSection<Content: View>: View {
    let title: String
    let color: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 1.5).fill(color).frame(width: 14, height: 3)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .tracking(1.5)
                    .foregroundStyle(Theme.ink.opacity(0.6))
            }
            content
        }
    }
}

#Preview {
    @Previewable @State var day = Date.now
    ZStack {
        GridPaper().ignoresSafeArea()
        TodayView(day: $day)
            .padding(.horizontal, 24)
    }
    .modelContainer(for: DayPage.self, inMemory: true)
    .environment(CalendarStore())
}
