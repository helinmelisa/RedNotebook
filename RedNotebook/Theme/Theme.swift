import SwiftUI

enum Theme {
    // Cover
    static let coverRed = Color(red: 0.72, green: 0.09, blue: 0.11)
    static let coverRedDark = Color(red: 0.45, green: 0.04, blue: 0.06)
    static let coverRedLight = Color(red: 0.84, green: 0.18, blue: 0.18)
    static let stitch = Color(red: 0.95, green: 0.80, blue: 0.70).opacity(0.75)
    static let band = Color(red: 0.12, green: 0.10, blue: 0.10)

    // Pages
    static let paper = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let grid = Color(red: 0.55, green: 0.65, blue: 0.75).opacity(0.22)
    static let ink = Color(red: 0.16, green: 0.16, blue: 0.20)
    static let ribbon = Color(red: 0.78, green: 0.10, blue: 0.14)

    // Background behind the notebook
    static let desk = Color(red: 0.86, green: 0.82, blue: 0.76)

    /// Hobonichi's 3.7 mm grid, roughly in points on an iPhone.
    static let gridSpacing: CGFloat = 14
}

/// Small deterministic random generator so textures look the same on every render.
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
