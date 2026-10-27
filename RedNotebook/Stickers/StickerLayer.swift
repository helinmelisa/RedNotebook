import SwiftData
import SwiftUI

/// Stickers stuck on a day page. Tap one to select it, then drag, pinch and twist it.
struct StickerLayer: View {
    let page: DayPage
    /// The diary page's stickers instead of the Today page's.
    var onDiary = false
    @Binding var selection: PersistentIdentifier?

    @Environment(\.modelContext) private var context
    @State private var writingOn: StickerPlacement?
    /// A sticky note being rewritten in the note maker.
    @State private var rewritingNote: StickerPlacement?
    @State private var draft = ""

    var body: some View {
        GeometryReader { geo in
            ForEach(page.stickers(onDiary: onDiary)) { placement in
                if let choice = placement.choice {
                    PlacedSticker(placement: placement, choice: choice, pageWidth: geo.size.width,
                                  isSelected: selection == placement.persistentModelID,
                                  onTap: { toggleSelection(placement) },
                                  onWrite: { startWriting(on: placement) },
                                  onDelete: { delete(placement) })
                        .position(x: placement.x * geo.size.width, y: placement.y)
                }
            }
        }
        .onChange(of: selection) { _, selected in
            // Framed photos that were just added ask for their caption right away
            guard let selected,
                  let placement = page.sortedStickers.first(where: { $0.persistentModelID == selected }),
                  StickerKind(rawValue: placement.kindRaw) == .polaroid, placement.text.isEmpty,
                  Date.now.timeIntervalSince(placement.createdAt) < 3 else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(700)) // let it drop onto the page first
                startWriting(on: placement)
            }
        }
        .sheet(item: $rewritingNote) { note in
            NoteMaker(initialStyle: NoteStyle(value: note.value), initialText: note.text) { style, text, _ in
                note.value = style.value
                note.text = text
            }
        }
        .alert("Write on it", isPresented: Binding(get: { writingOn != nil }, set: { if !$0 { writingOn = nil } })) {
            TextField("A word or two", text: $draft)
            Button("Done") {
                writingOn?.text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                writingOn = nil
            }
            Button("Cancel", role: .cancel) { writingOn = nil }
        }
    }

    private func toggleSelection(_ placement: StickerPlacement) {
        UISelectionFeedbackGenerator().selectionChanged()
        if selection == placement.persistentModelID {
            selection = nil
        } else {
            placement.z = (page.sortedStickers.last?.z ?? 0) + 1 // bring to front
            selection = placement.persistentModelID
        }
    }

    private func startWriting(on placement: StickerPlacement) {
        if StickerKind(rawValue: placement.kindRaw) == .note {
            rewritingNote = placement
            return
        }
        draft = placement.text
        writingOn = placement
    }

    private func delete(_ placement: StickerPlacement) {
        selection = nil
        withAnimation(.snappy) { context.delete(placement) }
    }
}

extension DayPage {
    /// Sticks a new sticker near the top of the page, slightly tilted like it was stuck by hand.
    func addSticker(_ choice: StickerChoice, in context: ModelContext, onDiary: Bool = false) -> StickerPlacement {
        let placement = StickerPlacement(choice: choice,
                                         x: .random(in: 0.3...0.7),
                                         y: .random(in: 140...260),
                                         rotation: .random(in: -12...12),
                                         z: (sortedStickers.last?.z ?? 0) + 1)
        placement.onDiary = onDiary
        context.insert(placement)
        placement.page = self
        return placement
    }
}

private struct PlacedSticker: View {
    @Bindable var placement: StickerPlacement
    let choice: StickerChoice
    let pageWidth: CGFloat
    let isSelected: Bool
    var onTap: () -> Void
    var onWrite: () -> Void
    var onDelete: () -> Void

    @GestureState private var drag: CGSize = .zero
    @GestureState private var pinch: CGFloat = 1
    @GestureState private var twist: Angle = .zero
    /// Held up off the page, just peeled from the sheet
    @State private var lifted = false

    var body: some View {
        StickerContent(choice: choice, text: placement.text)
            .padding(8)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.red.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Theme.red)
                    }
                    .offset(x: 10, y: -10)
                    .accessibilityLabel("Remove sticker")
                }
            }
            .overlay(alignment: .topLeading) {
                if isSelected && placement.isWritable {
                    Button(action: onWrite) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Theme.ink)
                    }
                    .offset(x: -10, y: -10)
                    .accessibilityLabel("Write on sticker")
                }
            }
            .scaleEffect(placement.scale * pinch * (lifted ? 1.35 : 1))
            .rotationEffect(.degrees(placement.rotation + (lifted ? 8 : 0)) + twist)
            .shadow(color: .black.opacity(lifted ? 0.25 : 0), radius: lifted ? 14 : 0, x: 0, y: lifted ? 12 : 0)
            .offset(drag)
            .onAppear(perform: dropIfNew)
            .onTapGesture(perform: onTap)
            .gesture(transform, including: isSelected ? .all : .subviews)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Sticker")
            .accessibilityHint(isSelected ? "Drag to move, pinch to resize, twist to rotate" : "Tap to select")
    }

    /// A sticker that was just added peels off, hangs in the air for a moment and presses down onto the page.
    private func dropIfNew() {
        guard Date.now.timeIntervalSince(placement.createdAt) < 2 else { return }
        lifted = true
        SoundEffects.shared.play(.peel)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.spring(response: 0.38, dampingFraction: 0.62)) { lifted = false }
            try? await Task.sleep(for: .milliseconds(220))
            SoundEffects.shared.play(.stick)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    private var transform: some Gesture {
        let move = DragGesture()
            .updating($drag) { value, state, _ in state = value.translation }
            .onEnded { value in
                placement.x = min(max(placement.x + value.translation.width / pageWidth, 0), 1)
                placement.y = max(placement.y + value.translation.height, 0)
            }
        let resize = MagnifyGesture()
            .updating($pinch) { value, state, _ in state = value.magnification }
            .onEnded { value in placement.scale = min(max(placement.scale * value.magnification, 0.3), 4) }
        let rotate = RotateGesture()
            .updating($twist) { value, state, _ in state = value.rotation }
            .onEnded { value in placement.rotation += value.rotation.degrees }

        return move.simultaneously(with: resize.simultaneously(with: rotate))
    }
}
