//
//  Colors+.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

extension Color {
    static let mainColor = Color(hex: "#00B463")
    static let deepNavyBlue = Color(hex: "#003366")
    static let greenAurora = Color(hex: "#4CA376")
    static let softLavender = Color(hex: "#E5E5FA")
    static let warmGray = Color(hex: "#A8A9A9")
    static let midnightBlue = Color(hex: "#191970")
    static let coralPink = Color(hex: "#FF6F61")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 1.0
            g = 1.0
            b = 1.0
        }

        self.init(red: r, green: g, blue: b)
    }
}
