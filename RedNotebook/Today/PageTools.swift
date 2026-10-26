import PhotosUI
import SwiftData
import SwiftUI

/// What the tools are doing on the open page, shared between the page and the tool dock around it.
@Observable
final class PageTools {
    var selectedSticker: PersistentIdentifier?
    var isDrawing = false

    /// Moving a sticker or drawing: drags belong to the page, so it neither scrolls nor turns.
    var isBusy: Bool { selectedSticker != nil || isDrawing }
}

extension View {
    /// The floating tools around a day page (stickers, photos and the pen) and their "Done" buttons.
    /// `onDiary` puts what's added on the diary page instead of the Today page.
    func pageTools(_ tools: PageTools, day: Date, onDiary: Bool = false) -> some View {
        modifier(PageToolsOverlay(tools: tools, day: day, onDiary: onDiary))
    }
}

private struct PageToolsOverlay: ViewModifier {
    @Bindable var tools: PageTools
    let day: Date
    let onDiary: Bool

    @Environment(\.modelContext) private var context
    @State private var showingStickers = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                Group {
                    if tools.selectedSticker != nil {
                        doneButton { tools.selectedSticker = nil }
                            .padding(.bottom, 20)
                    } else if !tools.isDrawing {
                        toolDock
                    }
                }
                .padding(.leading, 28)
                .padding(.trailing, 44)
            }
            .overlay(alignment: .topTrailing) {
                // The pen palette covers the bottom of the screen, so "Done" sits at the top,
                // over the day arrows so a stray tap can't flip the page mid-drawing
                if tools.isDrawing {
                    doneButton { tools.isDrawing = false }
                        .padding(.top, 24)
                        .padding(.trailing, 44)
                }
            }
            .sheet(isPresented: $showingStickers) {
                StickerDrawer(onPick: stick)
            }
            .onChange(of: day) {
                tools.selectedSticker = nil
                tools.isDrawing = false
            }
    }

    /// Floating tools for decorating the page: stickers, a photo of the day and the pen.
    private var toolDock: some View {
        HStack(spacing: 4) {
            dockButton("star.bubble", label: "Add sticker") { showingStickers = true }
            Rectangle().fill(Theme.hairline).frame(width: 1, height: 20)
            PhotoFramePicker(onPick: stick) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 40, height: 36)
            }
            .accessibilityLabel("Add photos of the day")
            Rectangle().fill(Theme.hairline).frame(width: 1, height: 20)
            dockButton("pencil.tip", label: "Draw") {
                tools.selectedSticker = nil
                tools.isDrawing = true
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Capsule().fill(Theme.paper))
        .overlay(Capsule().stroke(Theme.hairline, lineWidth: 1))
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.bottom, 18)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }

    /// Stickers and framed photos land on the page selected, ready to move (or to write a caption on).
    private func stick(_ choice: StickerChoice) {
        let placement = DayPage.page(for: day, in: context).addSticker(choice, in: context, onDiary: onDiary)
        tools.selectedSticker = placement.persistentModelID
    }

    private func dockButton(_ systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.snappy) { action() }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 40, height: 36)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func doneButton(_ action: @escaping () -> Void) -> some View {
        Button("Done") { withAnimation(.snappy) { action() } }
            .font(Theme.serif(14, .semibold))
            .foregroundStyle(Theme.paper)
            .padding(.horizontal, 22)
            .padding(.vertical, 9)
            .background(Capsule().fill(Theme.accent))
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
