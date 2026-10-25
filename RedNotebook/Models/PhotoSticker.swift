import Foundation
import SwiftData
import UIKit

/// A sticker cut out of one of your photos, kept in the sticker book.
@Model
final class PhotoSticker {
    /// Transparent PNG.
    @Attribute(.externalStorage) var imageData: Data?
    var createdAt: Date = Date.now

    /// Deleting the sticker from the book also peels it off every page.
    @Relationship(deleteRule: .cascade, inverse: \StickerPlacement.photo)
    var placements: [StickerPlacement]? = []

    init(imageData: Data) {
        self.imageData = imageData
    }

    var image: UIImage? {
        imageData.flatMap(UIImage.init(data:))
    }
}
