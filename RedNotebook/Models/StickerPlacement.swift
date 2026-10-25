import Foundation
import SwiftData

enum StickerKind: String {
    case emoji, drawn, photo, polaroid
}

/// Something you can stick on a page.
enum StickerChoice {
    case emoji(String)
    case drawn(DrawnSticker)
    case photo(PhotoSticker)
    /// A photo of the day in a polaroid frame (JPEG data, not cut out).
    case polaroid(Data)
}

/// A sticker stuck on a day page, with where it sits and how it's been resized and turned.
@Model
final class StickerPlacement {
    var kindRaw: String = StickerKind.emoji.rawValue
    /// The emoji itself, or the drawn sticker's name. Empty for photo stickers.
    var value: String = ""
    /// Horizontal position as a fraction of the page width, so it survives different screen sizes.
    var x: Double = 0.5
    /// Vertical position in points from the top of the page.
    var y: Double = 200
    var scale: Double = 1
    /// Degrees.
    var rotation: Double = 0
    var z: Int = 0
    /// When it was stuck on. Stickers from before this existed default to long ago, so they don't animate.
    var createdAt: Date = Date.distantPast
    /// What's written on it (tapes, labels and notes).
    var text: String = ""
    /// The photo, for polaroids.
    @Attribute(.externalStorage) var imageData: Data?
    var page: DayPage?
    var photo: PhotoSticker?

    init(choice: StickerChoice, x: Double, y: Double, rotation: Double, z: Int) {
        switch choice {
        case .emoji(let emoji):
            kindRaw = StickerKind.emoji.rawValue
            value = emoji
        case .drawn(let drawn):
            kindRaw = StickerKind.drawn.rawValue
            value = drawn.rawValue
        case .photo(let photo):
            kindRaw = StickerKind.photo.rawValue
            self.photo = photo
        case .polaroid(let data):
            kindRaw = StickerKind.polaroid.rawValue
            imageData = data
        }
        self.x = x
        self.y = y
        self.rotation = rotation
        self.z = z
        self.createdAt = .now
    }

    var isWritable: Bool {
        switch StickerKind(rawValue: kindRaw) {
        case .drawn: DrawnSticker(rawValue: value)?.isWritable ?? false
        case .polaroid: true
        default: false
        }
    }

    var choice: StickerChoice? {
        switch StickerKind(rawValue: kindRaw) {
        case .emoji: .emoji(value)
        case .drawn: DrawnSticker(rawValue: value).map { .drawn($0) }
        case .photo: photo.map { .photo($0) }
        case .polaroid: imageData.map { .polaroid($0) }
        case nil: nil
        }
    }
}
