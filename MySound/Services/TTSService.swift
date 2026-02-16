//
//  TTSService.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import Foundation
import AVFoundation
import Combine
import os

class TTSService: NSObject, ObservableObject {
    
    private let synthesizer = AVSpeechSynthesizer()
    private let logger = Logger(subsystem: "com.yourcompany.MySound", category: "TTSService")
    
    // Estado reativo da fala
    @Published private(set) var isSpeaking: Bool = false
    
    weak var chapterViewModel: ChapterViewModel?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func attachWiewModel(_ viewModel: ChapterViewModel) {
        self.chapterViewModel = viewModel
    }
    
    func speak(_ text: String, languageCode: String) {
        // Reset before starting a new utterance
        
        
        // If already speaking, stop immediately before starting new
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Configure audio session
        configureAudioSession()
        
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.02
        utterance.preUtteranceDelay = 0.0
        utterance.postUtteranceDelay = 0.05
        utterance.volume = 1.0
        
        if let voice = getEnglishVoiceByName("Allison") {
            utterance.voice = voice
        }
        else if let preferred = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language == languageCode && $0.quality == .enhanced }) {
            utterance.voice = preferred
        } else if let exact = AVSpeechSynthesisVoice(language: languageCode) {
            utterance.voice = exact
        } else if let baseCode = languageCode.split(separator: "-").first,
                  let base = AVSpeechSynthesisVoice(language: String(baseCode)) {
            utterance.voice = base
            logger.warning("Specific voice \(languageCode, privacy: .public) not found, using base \(String(baseCode), privacy: .public)")
        } else {
            logger.error("No voice available for \(languageCode, privacy: .public). Using system default.")
        }

        synthesizer.speak(utterance)
        // isSpeaking will be updated by delegate callbacks
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // isSpeaking will be updated by delegate callbacks
        
        
    }
    
    func getEnglishVoiceByName(_ name: String) -> AVSpeechSynthesisVoice? {
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        return voices.first(where: {
            $0.language.starts(with: "en") && $0.name.localizedCaseInsensitiveContains(name)
        })
    }
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [])
            try session.setActive(true, options: [])
        } catch {
            logger.error("Failed to configure AVAudioSession: \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension TTSService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
       
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            // Reset after finishing
           /* self?.chapterViewModel?.nextWord()*/  // depois de acabar de fazer a leitura
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            // Reset after canceling
//            self?.chapterViewModel?.reset()
        }
    }
    
    
//    func speechSynthesizer(
//        _ synthesizer: AVSpeechSynthesizer,
//        willSpeakRangeOfSpeechString characterRange: NSRange,
//        utterance: AVSpeechUtterance
//    ) {
//        guard let viewModel = chapterViewModel else { return }
//        viewModel.updateHighlight(using: characterRange)
//    }
    
    private func clean(_ word: String) -> String {
        word.lowercased()
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "!", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

