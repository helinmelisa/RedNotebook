import SwiftUI

/// Draws any sticker at its natural size.
struct StickerContent: View {
    let choice: StickerChoice

    var body: some View {
        switch choice {
        case .emoji(let emoji):
            Text(emoji)
                .font(.system(size: 48))
                .stickerOutline()
        case .drawn(let drawn):
            DrawnStickerView(sticker: drawn)
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
