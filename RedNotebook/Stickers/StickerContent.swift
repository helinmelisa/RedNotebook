import SwiftUI

/// Draws any sticker at its natural size.
struct StickerContent: View {
    let choice: StickerChoice
    var text: String = ""

    var body: some View {
        switch choice {
        case .emoji(let emoji):
            Text(emoji)
                .font(.system(size: 48))
                .stickerOutline()
        case .drawn(let drawn):
            DrawnStickerView(sticker: drawn, text: text)
        case .photos(let style, let photos):
            PhotoFrameView(style: style, photos: photos, caption: text)
        case .washi(let style, _):
            CustomWashi(style: style, text: text)
        case .note(let style, _):
            NoteSticker(style: style, text: text)
        case .photo(let photo):
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 110, maxHeight: 110)
                    .stickerOutline(2.5)
            }
        }
    }
}

enum StickerEmoji {
    static let all = [
        "🌸", "🌷", "🌻", "🍀", "🌿", "🍂", "🌈", "⭐️", "🌙", "☀️",
        "❤️", "🧡", "💛", "💚", "💙", "💜", "🤍", "💕", "✨", "🎀",
        "☕️", "🍰", "🍓", "🍑", "🍜", "🥐", "🍷", "🧁",
        "📚", "✏️", "📌", "📎", "🎧", "📷", "✈️", "🚲", "🏠", "🎂",
        "🐱", "🐶", "🐰", "🐻", "🦊", "🐥", "🦋", "🐝",
        "😊", "🥰", "😴", "🥳", "🤓", "😎",
    ]
}

/// A real photo in a white polaroid frame, with room for a handwritten caption.
struct PolaroidPhoto: View {
    let data: Data
    var caption: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let image = UIImage(data: data) {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    Color(white: 0.85)
                }
            }
            .frame(width: 104, height: 104)
            .clipped()
            // A faint inner shadow, like a print set into the frame
            .overlay(Rectangle().stroke(.black.opacity(0.08), lineWidth: 1))

            Text(caption.isEmpty ? " " : caption)
                .font(Theme.handwriting(size: 17).weight(.semibold))
                .foregroundStyle(Theme.ink.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: 104, height: 30)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background(Color(red: 0.995, green: 0.99, blue: 0.98))
        .shadow(color: .black.opacity(0.22), radius: 2.5, x: 1, y: 2)
        .rotationEffect(.degrees(-2))
    }
}
