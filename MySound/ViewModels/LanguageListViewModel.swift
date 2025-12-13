//
//  LanguageListViewModel.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import Combine

class LanguageListViewModel: ObservableObject {
    @Published var languages: [Language] = StoreService.shared.getLanguages()
    
    func addLanguage(_ language: Language) {
        languages.append(language)
        StoreService.shared.saveLanguages(languages)
    }
}
