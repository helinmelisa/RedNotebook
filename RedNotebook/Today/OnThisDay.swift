import SwiftData
import SwiftUI

/// Pages from one month and one year before this one, tucked in like old clippings. Tap one to flip back to it.
struct OnThisDay: View {
    let day: Date
    var onOpen: (Date) -> Void

    @Environment(\.modelContext) private var context

    private struct Memory: Identifiable {
        let label: String
        let page: DayPage
        var id: Date { page.day }
    }

    var body: some View {
        let memories = findMemories()
        if !memories.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(title: "On this day", color: NotebookSection.diary.tabColor)
                ForEach(Array(memories.enumerated()), id: \.element.id) { index, memory in
                    Button { onOpen(memory.page.day) } label: {
                        MemoryClipping(label: memory.label, page: memory.page)
                            .rotationEffect(.degrees(index.isMultiple(of: 2) ? -0.8 : 0.9))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func findMemories() -> [Memory] {
        let calendar = Calendar.current
        let offsets: [(String, DateComponents)] = [
            ("One year ago", DateComponents(year: -1)),
            ("One month ago", DateComponents(month: -1)),
        ]
        return offsets.compactMap { label, offset in
            guard let date = calendar.date(byAdding: offset, to: day) else { return nil }
            let start = calendar.startOfDay(for: date)
            var descriptor = FetchDescriptor<DayPage>(predicate: #Predicate { $0.day == start })
            descriptor.fetchLimit = 1
            guard let page = try? context.fetch(descriptor).first, !page.isEmpty else { return nil }
            return Memory(label: label, page: page)
        }
    }
}

/// A slip of paper with the old page's mood, a line of it and its first photo.
private struct MemoryClipping: View {
    let label: String
    let page: DayPage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if let mood = page.mood {
                        MoodFace(mood: mood).frame(width: 16, height: 16)
                    }
                    Text(label.uppercased())
                        .font(Theme.eyebrow)
                        .tracking(1.2)
                        .foregroundStyle(Theme.accent)
                    Text(page.day.formatted(.dateTime.day().month(.abbreviated).year()))
                        .font(Theme.serif(11))
                        .foregroundStyle(Theme.inkTertiary)
                }
                Text(snippet)
                    .font(Theme.handwriting(size: 19))
                    .foregroundStyle(Theme.ink.opacity(0.85))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let photo = firstPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .padding(3)
                    .padding(.bottom, 8)
                    .background(Color(red: 0.995, green: 0.99, blue: 0.98))
                    .shadow(color: .black.opacity(0.2), radius: 1.5, x: 0.5, y: 1)
                    .rotationEffect(.degrees(4))
            }
        }
        .padding(12)
        .background(
            Rectangle()
                .fill(Color(red: 0.97, green: 0.93, blue: 0.84))
                .shadow(color: .black.opacity(0.12), radius: 2, x: 0.5, y: 1.5)
        )
        // A bit of tape holding it on
        .overlay(alignment: .top) {
            Rectangle()
                .fill(NotebookSection.diary.tabColor.opacity(0.55))
                .frame(width: 54, height: 13)
                .rotationEffect(.degrees(-3))
                .offset(y: -7)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens that day")
    }

    /// The diary if there is one, otherwise the answer, tasks or what was eaten.
    private var snippet: String {
        let candidates = [
            page.diaryText,
            page.promptAnswer,
            page.sortedItems.prefix(3).map(\.text).joined(separator: " · "),
            page.sortedNotes.map(\.text).joined(separator: " · "),
            page.sortedMeals.map(\.text).joined(separator: " · "),
        ]
        return candidates.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.first { !$0.isEmpty }
            ?? "A page with stickers and doodles."
    }

    private var firstPhoto: UIImage? {
        let framed = page.sortedStickers.first { $0.imageData != nil }?.imageData
        return (framed ?? page.outfitPhoto).flatMap(UIImage.init(data:))
    }
}
