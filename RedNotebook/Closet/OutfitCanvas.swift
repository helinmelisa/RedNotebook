import SwiftData
import SwiftUI

/// Your body photo with the worn clothes layered on top.
/// When `selection` is given, tapping a piece selects it and it can be dragged and pinched into place.
struct OutfitCanvas: View {
    let bodyImage: UIImage?
    let items: [ClothingItem]
    var selection: Binding<PersistentIdentifier?>? = nil

    /// Canvas proportions, roughly a full-length photo.
    static let aspectRatio: CGFloat = 3.0 / 5.0

    var body: some View {
        GeometryReader { geo in
            let canvas = geo.size
            ZStack {
                if let bodyImage {
                    Image(uiImage: bodyImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: canvas.width, height: canvas.height)
                } else {
                    Image(systemName: "figure.stand")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Theme.ink.opacity(0.12))
                        .padding(.vertical, canvas.height * 0.04)
                        .frame(width: canvas.width, height: canvas.height)
                }

                ForEach(items) { item in
                    ClothingLayer(item: item, canvas: canvas,
                                  isSelected: selection?.wrappedValue == item.persistentModelID,
                                  isEditable: selection != nil,
                                  onTap: { toggle(item) })
                }
            }
            .frame(width: canvas.width, height: canvas.height)
        }
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
    }

    private func toggle(_ item: ClothingItem) {
        guard let selection else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        selection.wrappedValue = selection.wrappedValue == item.persistentModelID ? nil : item.persistentModelID
    }
}

private struct ClothingLayer: View {
    @Bindable var item: ClothingItem
    let canvas: CGSize
    let isSelected: Bool
    let isEditable: Bool
    var onTap: () -> Void

    @GestureState private var drag: CGSize = .zero
    @GestureState private var pinch: CGFloat = 1

    var body: some View {
        if let image = item.image {
            let width = item.fitWidth * canvas.width * pinch
            let height = width * image.size.height / max(image.size.width, 1)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
                .overlay {
                    if isSelected {
                        Rectangle()
                            .stroke(Theme.coverRed.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    }
                }
                .position(x: item.fitX * canvas.width + drag.width,
                          y: item.fitTop * canvas.height + height / 2 + drag.height)
                .onTapGesture { if isEditable { onTap() } }
                .gesture(adjust(itemHeight: height), including: isSelected ? .all : .subviews)
                .accessibilityLabel(item.category.title)
                .accessibilityHint(isSelected ? "Drag to move, pinch to resize" : "Tap to adjust the fit")
        }
    }

    /// Moving and resizing saves the new fit on the piece, so it sits right every time it's worn.
    private func adjust(itemHeight: CGFloat) -> some Gesture {
        let move = DragGesture()
            .updating($drag) { value, state, _ in state = value.translation }
            .onEnded { value in
                item.fitX = min(max(item.fitX + value.translation.width / canvas.width, 0), 1)
                item.fitTop = min(max(item.fitTop + value.translation.height / canvas.height, -0.2), 1)
            }
        let resize = MagnifyGesture()
            .updating($pinch) { value, state, _ in state = value.magnification }
            .onEnded { value in
                // Grow around the centre: shift the top edge up by half the extra height
                let newWidth = min(max(item.fitWidth * value.magnification, 0.08), 1.5)
                let extra = itemHeight * (newWidth / item.fitWidth - 1)
                item.fitTop -= extra / 2 / canvas.height
                item.fitWidth = newWidth
            }
        return move.simultaneously(with: resize)
    }
}
