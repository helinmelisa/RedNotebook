import Foundation
import SwiftData

enum StickerKind: String {
    case emoji, drawn, photo, polaroid, washi, note
}

/// Something you can stick on a page.
enum StickerChoice {
    case emoji(String)
    case drawn(DrawnSticker)
    case photo(PhotoSticker)
    /// Photos of the day in a frame: a polaroid, instax, film strip or photo-booth strip (JPEGs, not cut out).
    case photos(PhotoFrameStyle, [Data])
    /// Your own washi tape, with what's written on it.
    case washi(WashiStyle, text: String)
    /// A sticky note, with what's written on it.
    case note(NoteStyle, text: String)
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
    /// The (first) photo, for framed photos. The frame style is kept in `value`.
    @Attribute(.externalStorage) var imageData: Data?
    /// Any further photos, for film and photo-booth strips.
    var extraImages: [Data]?
    /// Stuck on the day's diary page rather than its Today page.
    var onDiary: Bool = false
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
        case .photos(let style, let images):
            kindRaw = StickerKind.polaroid.rawValue
            value = style.rawValue
            imageData = images.first
            extraImages = images.count > 1 ? Array(images.dropFirst()) : nil
        case .washi(let style, let text):
            kindRaw = StickerKind.washi.rawValue
            value = style.value
            self.text = text
        case .note(let style, let text):
            kindRaw = StickerKind.note.rawValue
            value = style.value
            self.text = text
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
        case .polaroid, .washi, .note: true
        default: false
        }
    }

    var choice: StickerChoice? {
        switch StickerKind(rawValue: kindRaw) {
        case .emoji: .emoji(value)
        case .drawn: DrawnSticker(rawValue: value).map { .drawn($0) }
        case .photo: photo.map { .photo($0) }
        case .polaroid: imageData.map { .photos(PhotoFrameStyle(rawValue: value) ?? .polaroid, [$0] + (extraImages ?? [])) }
        case .washi: WashiStyle(value: value).map { .washi($0, text: text) }
        case .note: NoteStyle(value: value).map { .note($0, text: text) }
        case nil: nil
        }
    }
}
