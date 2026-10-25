import PhotosUI
import SwiftData
import SwiftUI

/// All stickers: your own from photos, the drawn pack and emoji. Tap one to pick it.
struct StickerPicker: View {
    var onPick: (StickerChoice) -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: \PhotoSticker.createdAt, order: .reverse) private var photoStickers: [PhotoSticker]

    @State private var photoItem: PhotosPickerItem?
    @State private var polaroidItem: PhotosPickerItem?
    @State private var isCutting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            section("My stickers") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 12)], spacing: 12) {
                    addPolaroid
                    addFromPhotos
                    ForEach(photoStickers) { sticker in
                        tile(.photo(sticker), size: 76)
                            .contextMenu {
                                Button("Delete sticker", systemImage: "trash", role: .destructive) {
                                    withAnimation(.snappy) { context.delete(sticker) }
                                }
                            }
                    }
                }
            }

            ForEach(DrawnSticker.Category.allCases, id: \.self) { category in
                section(category.rawValue) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 62), spacing: 2)], spacing: 6) {
                        ForEach(DrawnSticker.allCases.filter { $0.category == category }) { drawn in
                            tile(.drawn(drawn), size: 62)
                                .accessibilityLabel(drawn.name)
                        }
                    }
                    .stickerSheet()
                }
            }

            section("Emoji") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 48), spacing: 6)], spacing: 6) {
                    ForEach(StickerEmoji.all, id: \.self) { emoji in
                        Button { pick(.emoji(emoji)) } label: {
                            Text(emoji).font(.system(size: 32)).frame(width: 48, height: 48)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await makeSticker(from: item) }
        }
        .onChange(of: polaroidItem) { _, item in
            guard let item else { return }
            Task { await makePolaroid(from: item) }
        }
    }

    private var addFromPhotos: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            VStack(spacing: 4) {
                if isCutting {
                    ProgressView()
                    Text("Cutting…")
                } else {
                    Image(systemName: "photo.badge.plus").font(.system(size: 20))
                    Text("From Photos")
                }
            }
            .font(Theme.serif(11))
            .foregroundStyle(Theme.ink.opacity(0.55))
            .frame(width: 76, height: 76)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
        .disabled(isCutting)
    }

    /// A photo of the day, framed as a polaroid (the whole photo, not cut out).
    private var addPolaroid: some View {
        PhotosPicker(selection: $polaroidItem, matching: .images) {
            VStack(spacing: 4) {
                Image(systemName: "photo.on.rectangle").font(.system(size: 20))
                Text("Polaroid")
            }
            .font(Theme.serif(11))
            .foregroundStyle(Theme.inkSecondary)
            .frame(width: 66, height: 76)
            .background(
                Rectangle().fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 1, y: 1.5)
            )
            .rotationEffect(.degrees(-3))
        }
        .disabled(isCutting)
        .accessibilityLabel("Add a photo as a polaroid")
    }

    private func makePolaroid(from item: PhotosPickerItem) async {
        defer { polaroidItem = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let jpeg = await PhotoCutout.polaroidPhoto(from: data) else { return }
        pick(.polaroid(jpeg))
    }

    /// A fixed-size cell, so wide stickers like tapes shrink to fit instead of stretching the grid.
    private func tile(_ choice: StickerChoice, size: CGFloat) -> some View {
        Button { pick(choice) } label: {
            StickerContent(choice: choice)
                .scaleEffect(0.6)
                .frame(width: size, height: size * 0.85)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title: title, color: NotebookSection.stickers.tabColor)
            content()
        }
    }

    private func pick(_ choice: StickerChoice) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onPick(choice)
    }

    private func makeSticker(from item: PhotosPickerItem) async {
        isCutting = true
        defer { isCutting = false; photoItem = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let png = await PhotoCutout.makeSticker(from: data) else { return }
        withAnimation(.snappy) { context.insert(PhotoSticker(imageData: png)) }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Sheet version of the picker, opened from a day page.
struct StickerDrawer: View {
    var onPick: (StickerChoice) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                StickerPicker { choice in
                    onPick(choice)
                    dismiss()
                }
                .padding(20)
            }
            .background(GridPaper().ignoresSafeArea())
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .tint(Theme.red)
        .presentationDetents([.medium, .large])
    }
}

private extension View {
    /// A sheet of stickers: off-white backing paper with a soft edge, like the ones sold in stationery shops.
    func stickerSheet() -> some View {
        padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.995, green: 0.99, blue: 0.975))
                    .shadow(color: Color(red: 0.35, green: 0.25, blue: 0.15).opacity(0.14), radius: 3, x: 0, y: 1.5)
            )
    }
}
