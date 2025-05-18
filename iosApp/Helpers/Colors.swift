//
//  Colors.swift
//  iosApp
//
//  Created by Varun Ananthakrishnan on 5/17/25.
//

import SwiftUI
/*
extension Color {
    // Add static color property
    static let mintGreen = Color.fromHex("#6DD3B2")
    
    // Keep the existing hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
    
    // Add static method for hex colors
    static func fromHex(_ hex: String) -> Color {
        Color(hex: hex)
    }
}
*/
