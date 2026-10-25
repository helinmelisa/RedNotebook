import SwiftUI

/// The notebook's cover colour. The rest of the app takes its accent and ribbon from it.
enum CoverColor: String, CaseIterable, Identifiable {
    // Raw values are saved in settings: "red" is the wine red cover and stays the default.
    case red, teal, navy, pink, matcha

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
        case .matcha: "Matcha"
        }
    }

    var base: Color {
        switch self {
        case .red: Color(red: 0.66, green: 0.08, blue: 0.22)
        case .teal: Color(red: 0.05, green: 0.48, blue: 0.50)
        case .navy: Color(red: 0.13, green: 0.20, blue: 0.38)
        case .pink: Color(red: 0.95, green: 0.72, blue: 0.78)
        case .matcha: Color(red: 0.55, green: 0.66, blue: 0.40)
        }
    }

    /// The Home Screen icon in this colour (nil = the main wine red one). Made by Scripts/make_app_icon.swift.
    var iconName: String? {
        self == .red ? nil : "AppIcon-\(rawValue)"
    }

    var light: Color { base.mix(with: .white, by: 0.15) }
    var dark: Color { base.mix(with: .black, by: 0.42) }

    /// Readable on cream paper: the cover hue, deepened where the cover itself is too pale for text.
    var accent: Color {
        switch self {
        case .red: base
        case .teal: Color(red: 0.0, green: 0.43, blue: 0.45)
        case .navy: Color(red: 0.18, green: 0.30, blue: 0.58)
        case .pink: Color(red: 0.80, green: 0.36, blue: 0.50)
        case .matcha: Color(red: 0.33, green: 0.48, blue: 0.20)
        }
    }
}
