//
//  SpeechRecognitionService.swift
//  MySound
//
//  Created by apple on 2/17/26.
//

import Combine
import Foundation
import AVFoundation
import Speech

final class SpeechRecognitionService: ObservableObject {
    
    @Published var recognizedText: String = ""
    
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func transcribeAudio(from url: URL) async throws -> String {
        
        guard let recognizer else {
            throw NSError(domain: "SpeechRecognizer", code: 0)
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        return try await withCheckedThrowingContinuation { continuation in
            
            recognizer.recognitionTask(with: request) { result, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
}
