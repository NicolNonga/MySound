//
//  ChapterViewModel.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import Foundation
import Combine

class ChapterViewModel: ObservableObject {
    struct WordInfo {
        let text: String
        let range: Range<String.Index>
    }
    
    @Published var chapterText: String
    let languageCode: String
    @Published var highlightWordIndex: Int? = nil
    @Published private(set) var currentWord: String = ""
    
    @Published var words: [String] = []
    private(set) var wordInfos: [WordInfo] = []
    @Published var currentWordIndex: Int = 0

    private var timer: Timer?
    
    init(words: [String], languageCode: String) {
        self.words = words
        self.languageCode = languageCode
        self.chapterText =  words[0]
        self.currentWord = words[0]
//        self.words = wordInfos.map { $0.text }
    }
    
    func nextWord() {
        currentWordIndex += 1
        if currentWordIndex < words.count {
           
            currentWord = words[currentWordIndex]
            
            
            print("Index atual:", currentWordIndex)
            print("Palavra atual:", currentWord)
            print("Total palavras:", words.count)
        }
    }
    func previousWord() {
        if currentWordIndex > 0 {
            currentWordIndex -= 1
            
        }
    }

    
    func stopAutoAdvance(){
        timer?.invalidate()
        timer = nil
    }
    
    func reset(){
        currentWordIndex = 0
    }
        
}

