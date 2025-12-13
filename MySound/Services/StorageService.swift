//
//  StorageService.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import Foundation

class StoreService {
    private let languagesKey = "userLanguages"
    
    static let shared = StoreService()
    
    private init() {}
    
    func saveLanguages(_ languages: [Language]) {
        if let data = try? JSONEncoder().encode(languages) {
            UserDefaults.standard.set(data, forKey: languagesKey)
        }
    }
    
    func getLanguages() -> [Language] {
        if let data = UserDefaults.standard.data(forKey: languagesKey),
           let languages = try? JSONDecoder().decode([Language].self, from: data) {
            return languages
        }
        // Default languages with distinct colors
        return [
            Language(name: "English",    code: "en-GB", hexColor: "#007AFF"), // Blue
            Language(name: "French",     code: "fr-FR", hexColor: "#FF2D55"), // Pink/Red
            Language(name: "Spanish",    code: "es-ES", hexColor: "#FF9500"), // Orange
            Language(name: "Portuguese", code: "pt-BR", hexColor: "#34C759")  // Green
        ]
    }
}
