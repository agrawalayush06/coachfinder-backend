//
//  Colors.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public extension Color {
    static let appPrimary = Color(red: 0.35, green: 0.38, blue: 0.95) // Vibrant Indigo
    static let appAccent = Color(red: 0.20, green: 0.78, blue: 0.65)  // Teal mint

    // Balances
    static let owedPositive = Color(red: 0.16, green: 0.73, blue: 0.44) // Emerald Green (You are owed)
    static let owedNegative = Color(red: 0.92, green: 0.26, blue: 0.32) // Crimson Red (You owe)
    static let owedNeutral = Color.secondary

    // Backgrounds & Surfaces
    static let surfacePrimary = Color(UIColor.systemBackground)
    static let surfaceSecondary = Color(UIColor.secondarySystemBackground)
    static let surfaceTertiary = Color(UIColor.tertiarySystemBackground)
    static let surfaceCard = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
            : UIColor.white
    })

    // Borders
    static let cardBorder = Color(UIColor.separator.withAlphaComponent(0.3))
}
