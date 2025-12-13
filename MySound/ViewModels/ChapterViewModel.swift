//
//  ChapterViewModel.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import Foundation
import Combine

class ChapterViewModel: ObservableObject {
    @Published var chapterText: String
    let languageCode: String
    @Published var highlightWordIndex: Int? = nil
    
    @Published var words: [String] = []
    @Published var currentWordIndex: Int = 0

    private var timer: Timer?
    
    init(chapterText: String, languageCode: String) {
        self.chapterText = chapterText
        self.languageCode = languageCode
        
        self.words = chapterText.components(separatedBy: " ")
       
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
    
    
}

