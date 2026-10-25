import Foundation
import SwiftData
import UIKit

enum ClothingCategory: String, CaseIterable, Identifiable {
    case top, bottom, dress, outerwear, shoes, accessory

    var id: Self { self }

    var title: String {
        switch self {
        case .top: "Tops"
        case .bottom: "Bottoms"
        case .dress: "Dresses"
        case .outerwear: "Jackets"
        case .shoes: "Shoes"
        case .accessory: "Accessories"
        }
    }

    var emoji: String {
        switch self {
        case .top: "👚"
        case .bottom: "👖"
        case .dress: "👗"
        case .outerwear: "🧥"
        case .shoes: "👟"
        case .accessory: "👜"
        }
    }

    /// Drawing order on the body, back to front.
    var layer: Int {
        switch self {
        case .shoes: 0
        case .bottom: 1
        case .dress: 2
        case .top: 3
        case .outerwear: 4
        case .accessory: 5
        }
    }

    /// Categories taken off when this one is put on.
    var replaces: [ClothingCategory] {
        switch self {
        case .dress: [.dress, .top, .bottom]
        case .top, .bottom: [self, .dress]
        default: [self]
        }
    }

    /// Where a new piece lands on a full-length photo, as fractions of the canvas:
    /// horizontal centre, top edge, and width.
    var defaultFit: (x: Double, top: Double, width: Double) {
        switch self {
        case .top: (0.5, 0.17, 0.55)
        case .bottom: (0.5, 0.44, 0.45)
        case .dress: (0.5, 0.17, 0.58)
        case .outerwear: (0.5, 0.15, 0.66)
        case .shoes: (0.5, 0.88, 0.38)
        case .accessory: (0.75, 0.40, 0.30)
        }
    }
}

/// A piece of clothing in the closet, cut out of its photo.
@Model
final class ClothingItem {
    /// Transparent PNG.
    @Attribute(.externalStorage) var imageData: Data?
    var categoryRaw: String = ClothingCategory.top.rawValue
    var createdAt: Date = Date.now

    /// How the piece sits on the body photo, adjusted by hand once and remembered.
    var fitX: Double = 0.5
    var fitTop: Double = 0.2
    var fitWidth: Double = 0.5

    /// Days this piece was worn.
    var days: [DayPage]? = []

    init(imageData: Data, category: ClothingCategory) {
        self.imageData = imageData
        self.categoryRaw = category.rawValue
        let fit = category.defaultFit
        fitX = fit.x
        fitTop = fit.top
        fitWidth = fit.width
    }

    var category: ClothingCategory {
        ClothingCategory(rawValue: categoryRaw) ?? .top
    }

    var image: UIImage? {
        imageData.flatMap(UIImage.init(data:))
    }
}

/// The full-length photo of you that clothes are tried on.
@Model
final class BodyPhoto {
    @Attribute(.externalStorage) var imageData: Data?
    var createdAt: Date = Date.now

    init(imageData: Data) {
        self.imageData = imageData
    }

    var image: UIImage? {
        imageData.flatMap(UIImage.init(data:))
    }
}
