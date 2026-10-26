import SwiftUI

/// The notebook's cover colour. The rest of the app takes its accent and ribbon from it.
enum CoverColor: String, CaseIterable, Identifiable {
    // Raw values are saved in settings: "red" is the wine red cover and stays the default.
    case red, teal, navy, pink, barbie, hotPink, matcha, orange

    var id: Self { self }

    static let storageKey = "coverColor"

    /// The colour chosen in the cover picker (wine red until one is picked, or if an old colour was saved).
    static var current: CoverColor {
        CoverColor(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .red
    }

    var name: String {
        switch self {
        case .red: "Wine red"
        case .teal: "Teal"
        case .navy: "Navy"
        case .pink: "Pastel pink"
        case .barbie: "Barbie pink"
        case .hotPink: "Hot pink"
        case .matcha: "Matcha"
        case .orange: "Glossy orange"
        }
    }

    var base: Color {
        switch self {
        case .red: Color(red: 0.66, green: 0.08, blue: 0.22)
        case .teal: Color(red: 0.05, green: 0.48, blue: 0.50)
        case .navy: Color(red: 0.13, green: 0.20, blue: 0.38)
        case .pink: Color(red: 0.98, green: 0.82, blue: 0.86)
        case .barbie: Color(red: 0.88, green: 0.13, blue: 0.54)
        case .hotPink: Color(red: 1.0, green: 0.25, blue: 0.60)
        case .matcha: Color(red: 0.55, green: 0.66, blue: 0.40)
        case .orange: Color(red: 0.97, green: 0.46, blue: 0.10)
        }
    }

    /// The Home Screen icon in this colour (nil = the main wine red one). Made by Scripts/make_app_icon.swift.
    var iconName: String? {
        self == .red ? nil : "AppIcon-\(rawValue)"
    }

    /// The elastic band: the cover colour, a couple of shades deeper.
    var band: Color { base.mix(with: .black, by: 0.32 * depth) }

    var light: Color { base.mix(with: .white, by: 0.15) }
    var dark: Color { base.mix(with: .black, by: 0.42 * depth) }

    /// How deep the shading goes. Pastels get much lighter shadows, or they turn grey.
    private var depth: Double { self == .pink ? 0.4 : 1 }

    /// Readable on cream paper: the cover hue, deepened where the cover itself is too pale for text.
    var accent: Color {
        switch self {
        case .red: base
        case .teal: Color(red: 0.0, green: 0.43, blue: 0.45)
        case .navy: Color(red: 0.18, green: 0.30, blue: 0.58)
        case .pink: Color(red: 0.82, green: 0.42, blue: 0.55)
        case .barbie: Color(red: 0.82, green: 0.10, blue: 0.50)
        case .hotPink: Color(red: 0.90, green: 0.12, blue: 0.48)
        case .matcha: Color(red: 0.33, green: 0.48, blue: 0.20)
        case .orange: Color(red: 0.82, green: 0.36, blue: 0.04)
        }
    }

    /// A smooth, lacquered cover with a shine, instead of leather.
    var isGlossy: Bool { self == .orange || self == .barbie }
}
