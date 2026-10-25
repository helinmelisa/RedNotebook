import SwiftUI

/// The notebook's cover colour. The rest of the app takes its accent and ribbon from it.
enum CoverColor: String, CaseIterable, Identifiable {
    case red, navy, sage, mustard, lilac, pink, black

    var id: Self { self }

    static let storageKey = "coverColor"

    /// The colour chosen in the cover picker (red until one is picked).
    static var current: CoverColor {
        CoverColor(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .red
    }

    var name: String {
        switch self {
        case .red: "Red"
        case .navy: "Navy"
        case .sage: "Sage"
        case .mustard: "Mustard"
        case .lilac: "Lilac"
        case .pink: "Pink"
        case .black: "Black"
        }
    }

    var base: Color {
        switch self {
        case .red: Color(red: 0.72, green: 0.09, blue: 0.11)
        case .navy: Color(red: 0.13, green: 0.20, blue: 0.38)
        case .sage: Color(red: 0.45, green: 0.58, blue: 0.47)
        case .mustard: Color(red: 0.84, green: 0.63, blue: 0.18)
        case .lilac: Color(red: 0.62, green: 0.52, blue: 0.78)
        case .pink: Color(red: 0.90, green: 0.55, blue: 0.62)
        case .black: Color(red: 0.15, green: 0.15, blue: 0.17)
        }
    }

    /// The Home Screen icon in this colour (nil = the main red one). Made by Scripts/make_app_icon.swift.
    var iconName: String? {
        self == .red ? nil : "AppIcon-\(rawValue)"
    }

    var light: Color { base.mix(with: .white, by: 0.15) }
    var dark: Color { base.mix(with: .black, by: 0.42) }

    /// Readable on cream paper: the cover hue, deepened where the cover itself is too pale for text.
    var accent: Color {
        switch self {
        case .red: base
        case .navy: Color(red: 0.18, green: 0.30, blue: 0.58)
        case .sage: Color(red: 0.27, green: 0.45, blue: 0.32)
        case .mustard: Color(red: 0.68, green: 0.45, blue: 0.05)
        case .lilac: Color(red: 0.48, green: 0.35, blue: 0.70)
        case .pink: Color(red: 0.78, green: 0.30, blue: 0.45)
        case .black: Color(red: 0.72, green: 0.09, blue: 0.11) // a black notebook with a red ribbon
        }
    }
}
