//
//  PracticeText.swift
//  MySound
//
//  Created by apple on 1/28/26.
//
import Foundation

struct PracticeText: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let tokens: [String]
    
    // Status
    var isFavorite: Bool
    var isUnread: Bool
    
    // Category
    let category: TextCategory

}

enum TextCategory: String, CaseIterable, Identifiable{
    
    case all = "All"
    case daily = "Daily Conversation"
    case travel = "Travel"
    case work = "work"
    case favorites = "Favorites"
    case unread = "Unread"
    
    var id: String {self.rawValue}
}
// MARK: - Word-by-word practice models

/// Represents a single practice item (a word or short phrase)
struct PracticeItem: Identifiable, Hashable {
    let id = UUID()
    let term: String            // e.g., "father", "mother"
    let translation: String?    // optional translation/hint
    var isMastered: Bool = false
    var isFavorite: Bool = false
}

/// Represents a category that contains a list of practice items
struct PracticeCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String            // e.g., "Family", "Work", "Travel"
    var items: [PracticeItem]

    // Optional metadata/status
    var isPinned: Bool = false
    var isUnread: Bool = false
}

extension PracticeCategory {
    /// Convenience to find next item to practice (first not mastered)
    var nextItemToPractice: PracticeItem? {
        items.first { !$0.isMastered }
    }
}

