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
    
    @Published var words: [String] = []
    private(set) var wordInfos: [WordInfo] = []
    @Published var currentWordIndex: Int = 0

    private var timer: Timer?
    
    init(chapterText: String, languageCode: String) {
        self.chapterText = chapterText
        self.languageCode = languageCode
        
        self.wordInfos = Self.tokenize(chapterText)
        self.words = wordInfos.map { $0.text }
    }
    
    private static func tokenize(_ text: String) -> [WordInfo] {
        var result: [WordInfo] = []
        var i = text.startIndex
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        while i < text.endIndex {
            // Skip separators
            while i < text.endIndex, let scalar = text[i].unicodeScalars.first, separators.contains(scalar) {
                i = text.index(after: i)
            }
            guard i < text.endIndex else { break }
            var j = i
            while j < text.endIndex, let scalar = text[j].unicodeScalars.first, !separators.contains(scalar) {
                j = text.index(after: j)
            }
            let range = i..<j
            let word = String(text[range])
            result.append(WordInfo(text: word, range: range))
            i = j
        }
        return result
    }
    
    func startAutoAdvance(interval:TimeInterval = 0.8){
        stopAutoAdvance()
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true){[weak self] _ in
            guard let self = self else {return}
            
            if self.currentWordIndex < self.words.count - 1 {
                self.currentWordIndex += 1
            }else {
                self.stopAutoAdvance()
            }
        }
        
    }
    
    func stopAutoAdvance(){
        timer?.invalidate()
        timer = nil
    }
    
    func reset(){
        currentWordIndex = 0
    }
    
    func updateWordIndex(_ index: Int) {
        DispatchQueue.main.async {
            if index < self.words.count {
                self.currentWordIndex = index
            }
        }
    }
    
    func updateHighlight(using characterRange: NSRange) {
        guard let range = Range(characterRange, in: chapterText) else { return }
        let location = range.lowerBound
        if let idx = wordInfos.firstIndex(where: { $0.range.contains(location) }) {
            updateWordIndex(idx)
        }
    }
    
}

