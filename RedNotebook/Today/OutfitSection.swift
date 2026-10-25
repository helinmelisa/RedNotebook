import PhotosUI
import SwiftUI

/// "Today's outfit": a photo cut out like a sticker, with a handwritten note beside it.
struct OutfitSection: View {
    @Bindable var page: DayPage

    @State private var photoItem: PhotosPickerItem?
    @State private var isCutting = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            photo
            TextField("What I'm wearing…", text: $page.outfitNote, axis: .vertical)
                .lineLimit(3...)
                .font(Theme.handwriting(size: 21))
                .foregroundStyle(Theme.ink)
                .padding(.top, 6)
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await setPhoto(from: item) }
        }
    }

    @ViewBuilder
    private var photo: some View {
        if let data = page.outfitPhoto, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 120, maxHeight: 170)
                .stickerOutline(2.5)
                .rotationEffect(.degrees(-3))
                .contextMenu {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label("Change photo", systemImage: "photo")
                    }
                    Button("Remove photo", systemImage: "trash", role: .destructive) {
                        withAnimation(.snappy) { page.outfitPhoto = nil }
                    }
                }
                .accessibilityLabel("Outfit photo")
        } else {
            PhotosPicker(selection: $photoItem, matching: .images) {
                VStack(spacing: 6) {
                    if isCutting {
                        ProgressView()
                        Text("Cutting out…")
                    } else {
                        Image(systemName: "tshirt").font(.system(size: 24))
                        Text("Add outfit photo")
                            .multilineTextAlignment(.center)
                    }
                }
                .font(.system(size: 11, design: .serif))
                .foregroundStyle(Theme.ink.opacity(0.5))
                .frame(width: 100, height: 130)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
            }
            .disabled(isCutting)
        }
    }

    private func setPhoto(from item: PhotosPickerItem) async {
        isCutting = true
        defer { isCutting = false; photoItem = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let png = await PhotoCutout.makeSticker(from: data) else { return }
        withAnimation(.snappy) { page.outfitPhoto = png }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
