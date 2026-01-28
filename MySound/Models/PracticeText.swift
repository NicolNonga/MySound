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
