import SwiftData
import SwiftUI

/// The Stickers tab: your sticker book. Tapping a sticker sticks it on the selected day's page.
struct StickerBookView: View {
    let day: Date
    var onOpenDay: (Date) -> Void

    @Environment(\.modelContext) private var context
    @State private var lastAdded: Date?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("STICKER BOOK")
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .tracking(2)
                        .foregroundStyle(Theme.coverRed)
                    Text("Stickers")
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("Tap a sticker to add it to \(dayName). Long-press your own stickers to delete them.")
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Theme.ink.opacity(0.55))
                        .padding(.top, 4)
                    Rectangle().fill(NotebookSection.stickers.tabColor).frame(height: 2).padding(.top, 8)
                }

                StickerPicker(onPick: add)
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottom) {
            if lastAdded != nil {
                Button { onOpenDay(day) } label: {
                    Label("Added to \(dayName) · Open page", systemImage: "checkmark")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
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
        Calendar.current.isDateInToday(day) ? "today's page" : day.formatted(.dateTime.day().month(.wide))
    }

    private func add(_ choice: StickerChoice) {
        _ = DayPage.page(for: day, in: context).addSticker(choice, in: context)
        let added = Date.now
        withAnimation(.snappy) { lastAdded = added }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            if lastAdded == added { withAnimation(.snappy) { lastAdded = nil } }
        }
    }
}
