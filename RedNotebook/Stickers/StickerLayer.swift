import SwiftData
import SwiftUI

/// Stickers stuck on a day page. Tap one to select it, then drag, pinch and twist it.
struct StickerLayer: View {
    let page: DayPage
    @Binding var selection: PersistentIdentifier?

    @Environment(\.modelContext) private var context

    var body: some View {
        GeometryReader { geo in
            ForEach(page.sortedStickers) { placement in
                if let choice = placement.choice {
                    PlacedSticker(placement: placement, choice: choice, pageWidth: geo.size.width,
                                  isSelected: selection == placement.persistentModelID,
                                  onTap: { toggleSelection(placement) },
                                  onDelete: { delete(placement) })
                        .position(x: placement.x * geo.size.width, y: placement.y)
                }
            }
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

    private func delete(_ placement: StickerPlacement) {
        selection = nil
        withAnimation(.snappy) { context.delete(placement) }
    }
}

extension DayPage {
    /// Sticks a new sticker near the top of the page, slightly tilted like it was stuck by hand.
    func addSticker(_ choice: StickerChoice, in context: ModelContext) -> StickerPlacement {
        let placement = StickerPlacement(choice: choice,
                                         x: .random(in: 0.3...0.7),
                                         y: .random(in: 140...260),
                                         rotation: .random(in: -12...12),
                                         z: (sortedStickers.last?.z ?? 0) + 1)
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
    var onDelete: () -> Void

    @GestureState private var drag: CGSize = .zero
    @GestureState private var pinch: CGFloat = 1
    @GestureState private var twist: Angle = .zero

    var body: some View {
        StickerContent(choice: choice)
            .padding(8)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.coverRed.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Theme.coverRed)
                    }
                    .offset(x: 10, y: -10)
                    .accessibilityLabel("Remove sticker")
                }
            }
            .scaleEffect(placement.scale * pinch)
            .rotationEffect(.degrees(placement.rotation) + twist)
            .offset(drag)
            .onTapGesture(perform: onTap)
            .gesture(transform, including: isSelected ? .all : .subviews)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Sticker")
            .accessibilityHint(isSelected ? "Drag to move, pinch to resize, twist to rotate" : "Tap to select")
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
