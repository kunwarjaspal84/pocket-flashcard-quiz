//
//  ColorExtension.swift
//  PocketFlashcardQuiz
//
//  Created by Kunwardeep Singh on 2025-04-21.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgb: UInt64 = 0
        Scanner(string: hex.hasPrefix("#") ? String(hex.dropFirst()) : hex).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
