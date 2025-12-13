//
//  Language.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import Foundation
import SwiftUI

struct Language: Identifiable, Codable, Hashable {
    var  id: UUID = UUID()
    let name: String
    let code: String
    // Store color as hex so it's Codable
    let hexColor: String

    init(name: String, code: String, hexColor: String = "#FF3B30") {
        self.name = name
        self.code = code
        self.hexColor = hexColor
    }
    
    // Computed SwiftUI Color for UI usage
    var color: Color {
        Color(fromHex: hexColor) ?? .red
    }
    
    var firstLatterName: String {
        // Return up to first 2 characters, safely
        let endIndex = name.index(name.startIndex, offsetBy: min(2, name.count), limitedBy: name.endIndex) ?? name.endIndex
        return String(name[name.startIndex..<endIndex])
    }
}

// MARK: - Color Hex Helper
private extension Color {
    init?(fromHex hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }

        var value: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&value) else { return nil }

        switch cleaned.count {
        case 6:
            let r = Double((value & 0xFF0000) >> 16) / 255.0
            let g = Double((value & 0x00FF00) >> 8) / 255.0
            let b = Double(value & 0x0000FF) / 255.0
            self = Color(red: r, green: g, blue: b)
        case 8:
            let a = Double((value & 0xFF000000) >> 24) / 255.0
            let r = Double((value & 0x00FF0000) >> 16) / 255.0
            let g = Double((value & 0x0000FF00) >> 8) / 255.0
            let b = Double(value & 0x000000FF) / 255.0
            self = Color(red: r, green: g, blue: b).opacity(a)
        default:
            return nil
        }
    }
}

