import PhotosUI
import SwiftUI

/// Ways to frame photos of the day on a page.
enum PhotoFrameStyle: String, CaseIterable, Identifiable {
    // "" is the classic polaroid, so polaroids saved before there were styles still read correctly
    case polaroid = ""
    case instax, filmStrip, photoBooth

    var id: Self { self }

    var name: String {
        switch self {
        case .polaroid: "Polaroid"
        case .instax: "Instax mini"
        case .filmStrip: "Film strip · 3 photos"
        case .photoBooth: "Photo booth · 4 photos"
        }
    }

    var icon: String {
        switch self {
        case .polaroid: "photo"
        case .instax: "rectangle.portrait"
        case .filmStrip: "film"
        case .photoBooth: "rectangle.split.1x2"
        }
    }

    var photoCount: Int {
        switch self {
        case .polaroid, .instax: 1
        case .filmStrip: 3
        case .photoBooth: 4
        }
    }

    /// Width ÷ height of each photo slot.
    var aspect: CGFloat {
        switch self {
        case .polaroid: 1
        case .instax: 0.75
        case .filmStrip, .photoBooth: 4.0 / 3.0
        }
    }
}

/// Draws photos in their frame, with the handwritten caption where the frame has room for one.
struct PhotoFrameView: View {
    let style: PhotoFrameStyle
    let photos: [Data]
    var caption: String = ""

    var body: some View {
        switch style {
        case .polaroid:
            PolaroidPhoto(data: photos.first ?? Data(), caption: caption)
        case .instax:
            InstaxMini(photo: photos.first, caption: caption)
        case .filmStrip:
            FilmStrip(photos: photos, label: caption)
        case .photoBooth:
            PhotoBoothStrip(photos: photos, caption: caption)
        }
    }
}

/// One photo slot, filled to its frame (or a soft grey if there are fewer photos than slots).
private struct PhotoSlot: View {
    let data: Data?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Color(white: 0.82)
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }
}

private struct Caption: View {
    let text: String
    var size: CGFloat = 15

    var body: some View {
        Text(text.isEmpty ? " " : text)
            .font(Theme.handwriting(size: size).weight(.semibold))
            .foregroundStyle(Theme.ink.opacity(0.85))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}

private let frameWhite = Color(red: 0.995, green: 0.99, blue: 0.98)

private struct InstaxMini: View {
    let photo: Data?
    let caption: String

    var body: some View {
        VStack(spacing: 0) {
            PhotoSlot(data: photo, width: 72, height: 96)
            Caption(text: caption).frame(width: 72, height: 30)
        }
        .padding(.horizontal, 7)
        .padding(.top, 9)
        .background(frameWhite)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .shadow(color: .black.opacity(0.22), radius: 2.5, x: 1, y: 2)
        .rotationEffect(.degrees(3))
    }
}

/// A strip of 35mm film: three frames between rows of sprocket holes, with edge printing.
private struct FilmStrip: View {
    let photos: [Data]
    /// Written along the edge instead of the film's own code, if given.
    let label: String

    private let film = Color(red: 0.13, green: 0.12, blue: 0.13)

    var body: some View {
        HStack(spacing: 4) {
            edge(text: label.isEmpty ? "HME-2026-\(Calendar.current.component(.day, from: .now))" : label)
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    PhotoSlot(data: i < photos.count ? photos[i] : nil, width: 80, height: 60)
                }
            }
            .padding(.vertical, 8)
            edge(text: nil)
        }
        .padding(.horizontal, 4)
        .background(film)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 2)
        .rotationEffect(.degrees(-3))
    }

    /// A column of sprocket holes, with tiny printed text running down beside it (outer edge only).
    private func edge(text: String?) -> some View {
        HStack(spacing: 2) {
            if let text {
                Text(text)
                    .font(.system(size: 6, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(white: 0.78))
                    .lineLimit(1)
                    .fixedSize()
                    .rotationEffect(.degrees(90))
                    .frame(width: 7, height: 212)
            }
            VStack(spacing: 6) {
                ForEach(0..<14, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1).fill(Color(white: 0.82)).frame(width: 6, height: 7)
                }
            }
            .frame(height: 212)
            .clipped()
        }
    }
}

/// A photo-booth strip: four little photos stacked on white card.
private struct PhotoBoothStrip: View {
    let photos: [Data]
    let caption: String

    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<4, id: \.self) { i in
                PhotoSlot(data: i < photos.count ? photos[i] : nil, width: 58, height: 44)
            }
            Caption(text: caption, size: 13).frame(width: 58, height: 16)
        }
        .padding(6)
        .background(frameWhite)
        .shadow(color: .black.opacity(0.22), radius: 2, x: 1, y: 2)
        .rotationEffect(.degrees(4))
    }
}

/// A button that offers the frame styles, then lets you pick that many photos and hands back the framed choice.
struct PhotoFramePicker<Label: View>: View {
    var onPick: (StickerChoice) -> Void
    @ViewBuilder var label: Label

    @State private var style: PhotoFrameStyle = .polaroid
    @State private var showingPhotos = false
    @State private var items: [PhotosPickerItem] = []

    var body: some View {
        Menu {
            ForEach(PhotoFrameStyle.allCases) { option in
                Button(option.name, systemImage: option.icon) {
                    style = option
                    showingPhotos = true
                }
            }
        } label: {
            label
        }
        .photosPicker(isPresented: $showingPhotos, selection: $items, maxSelectionCount: style.photoCount,
                      selectionBehavior: .ordered, matching: .images)
        .onChange(of: items) { _, picked in
            guard !picked.isEmpty else { return }
            let chosenStyle = style
            Task {
                var photos: [Data] = []
                for item in picked {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let framed = await PhotoCutout.framedPhoto(from: data, aspect: chosenStyle.aspect) {
                        photos.append(framed)
                    }
                }
                items = []
                guard !photos.isEmpty else { return }
                onPick(.photos(chosenStyle, photos))
            }
        }
    }
}
