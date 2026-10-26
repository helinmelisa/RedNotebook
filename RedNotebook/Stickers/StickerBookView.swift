import SwiftData
import SwiftUI

/// The Stickers tab: your sticker book. Tapping a sticker sticks it on the selected day's diary page.
struct StickerBookView: View {
    let day: Date
    /// Turns to the day's diary page.
    var onOpenDiary: (Date) -> Void

    @Environment(\.modelContext) private var context
    @State private var lastAdded: Date?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PageTitle(eyebrow: "Sticker book", title: "Stickers", color: NotebookSection.stickers.tabColor,
                          subtitle: "Tap a sticker to add it to \(dayName). Long-press your own stickers to delete them.")

                StickerPicker(onPick: add)
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
            .notebookPage()
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottom) {
            if lastAdded != nil {
                Button { onOpenDiary(day) } label: {
                    Label("Added to \(dayName) · Open diary", systemImage: "checkmark")
                        .font(Theme.serif(13, .semibold))
                        .foregroundStyle(Theme.paper)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Theme.ink.opacity(0.85)))
                }
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var dayName: String {
        Calendar.current.isDateInToday(day) ? "today's diary" : "the diary on " + day.formatted(.dateTime.day().month(.wide))
    }

    private func add(_ choice: StickerChoice) {
        _ = DayPage.page(for: day, in: context).addSticker(choice, in: context, onDiary: true)
        let added = Date.now
        withAnimation(.snappy) { lastAdded = added }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            if lastAdded == added { withAnimation(.snappy) { lastAdded = nil } }
        }
    }
}
