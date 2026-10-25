import SwiftUI
import SwiftData

/// A row of little sticky notes, slightly tilted like real paper ones.
struct QuickNotesStrip: View {
    @Bindable var page: DayPage

    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(Array(page.sortedNotes.enumerated()), id: \.element.id) { index, note in
                    StickyNote(note: note, tilt: index.isMultiple(of: 2) ? -2 : 1.5,
                               onDelete: { delete(note) })
                }
                addButton
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.hidden)
    }

    private var addButton: some View {
        Button(action: add) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Theme.ink.opacity(0.4))
                .frame(width: 70, height: 110)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add a note")
    }

    private func add() {
        let note = QuickNote(colorIndex: (page.notes ?? []).count % Theme.stickyColors.count)
        withAnimation(.snappy) { note.page = page }
    }

    private func delete(_ note: QuickNote) {
        withAnimation(.snappy) { context.delete(note) }
    }
}

private struct StickyNote: View {
    @Bindable var note: QuickNote
    let tilt: Double
    var onDelete: () -> Void

    var body: some View {
        TextField("Note…", text: $note.text, axis: .vertical)
            .lineLimit(5, reservesSpace: true)
            .font(Theme.handwriting(size: 19))
            .foregroundStyle(Theme.ink)
            .padding(10)
            .frame(width: 120, height: 110, alignment: .topLeading)
            .background(
                Theme.stickyColors[note.colorIndex % Theme.stickyColors.count]
                    .shadow(.drop(color: .black.opacity(0.15), radius: 2, x: 1, y: 2))
            )
            .rotationEffect(.degrees(tilt))
            .contextMenu {
                Picker("Colour", selection: $note.colorIndex) {
                    ForEach(Theme.stickyColors.indices, id: \.self) { index in
                        Text(Theme.stickyColorNames[index]).tag(index)
                    }
                }
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
    }
}
