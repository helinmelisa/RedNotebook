import PhotosUI
import SwiftData
import SwiftUI

/// "Today's outfit": the outfit from the closet or a photo, with a handwritten note beside it.
struct OutfitSection: View {
    @Bindable var page: DayPage
    var onDressUp: () -> Void

    @Query(sort: \BodyPhoto.createdAt, order: .reverse) private var bodyPhotos: [BodyPhoto]

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
        if !page.wornItems.isEmpty {
            // Dressed up in the closet: show the outfit on you, tap to change it
            Button(action: onDressUp) {
                OutfitCanvas(bodyImage: bodyPhotos.first?.image, items: page.wornItems)
                    .frame(width: 110)
                    .stickerOutline(2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Outfit from the closet. Open closet")
        } else if let data = page.outfitPhoto, let image = UIImage(data: data) {
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
            VStack(spacing: 8) {
                Button(action: onDressUp) {
                    placeholderLabel("Dress up", systemImage: "hanger")
                }
                .buttonStyle(.plain)
                PhotosPicker(selection: $photoItem, matching: .images) {
                    if isCutting {
                        placeholderLabel("Cutting out…", systemImage: "hourglass")
                    } else {
                        placeholderLabel("Add photo", systemImage: "photo")
                    }
                }
                .disabled(isCutting)
            }
            .frame(width: 100)
        }
    }

    private func placeholderLabel(_ title: String, systemImage: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage).font(.system(size: 18))
            Text(title)
        }
        .font(Theme.serif(11))
        .foregroundStyle(Theme.ink.opacity(0.55))
        .frame(width: 100, height: 62)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        )
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
