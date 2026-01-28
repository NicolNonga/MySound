//
//  HomeViewMode.swift
//  MySound
//
//  Created by apple on 1/28/26.
//

import Foundation
import Combine

class HomeViewMode: ObservableObject {
    
    @Published var texts: [PracticeText] = []
    @Published var selectedCategory: TextCategory = .all
    
    private let repository = TextService.shared
    
    init() {
        loadTexts()
    }
    
    func loadTexts()
    {
        texts = repository.getAllTexts()
    }
    var filteredTexts: [PracticeText] {
        switch selectedCategory {
        case .all:
            return texts
        case .favorites:
            return texts.filter{$0.isFavorite}
        case .unread:
            return texts.filter{$0.isUnread}
        
        case .daily, .travel, .work:
            return  texts.filter {$0.category == selectedCategory}
        }
    }
    
    func toggleFavorite(_ textID: UUID){
        if let index = texts.firstIndex(where: {$0.id == textID})
            {
            texts[index].isFavorite.toggle()
        }
    }
    func markAsRead(_ textID: UUID){
        if let index = texts.firstIndex(where: {$0.id == textID})
            {
            texts[index].isUnread = false;
        }
    }
}
