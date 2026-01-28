//
//  TextService.swift
//  MySound
//
//  Created by apple on 1/28/26.
//

import Foundation

class TextService {
    static let shared = TextService()
    
    
    func getAllTexts() -> [PracticeText] {
        
        return [
        PracticeText(
        title: "Daily Conversation",
        content: "Hello, how are you today? I hope you are doing well and enjoying your day.",
        tokens: "Hello, how are you today? I hope you are doing well and enjoying your day.".components(separatedBy: " "),
        isFavorite: false,
        isUnread: true,
        category: .daily
        ),
        PracticeText(
        title: "Travel English",
        content: "I would like to book a hotel room for two nights. Can you help me with that?",
        tokens: "I would like to book a hotel room for two nights. Can you help me with that?".components(separatedBy: " "),
        isFavorite: false,
        isUnread: true,
        category: .travel
        ),
        PracticeText(
        title: "Work English",
        content: "We will schedule a meeting to discuss the project and define the next steps.",
        tokens: "We will schedule a meeting to discuss the project and define the next steps.".components(separatedBy: " "),
        isFavorite: false,
        isUnread: true,
        category: .work
        )
        ]
    }
}
