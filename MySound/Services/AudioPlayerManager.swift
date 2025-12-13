//
//  AudioPlayerManager.swift
//  MySound
//
//  Created by apple on 12/12/25.
//

import Combine
import Foundation
import AVFoundation

class AudioPlayerManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    
    
    func play(audioURL: URL) {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        
    }
    
}

//extension AudioPlayerManager: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        isPlaying = false
//    }
//}
