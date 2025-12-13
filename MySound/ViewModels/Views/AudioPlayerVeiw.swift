//
//  AudioPlayerVeiw.swift
//  MySound
//
//  Created by apple on 12/12/25.
//

import SwiftUI

struct AudioPlayerVeiw: View {
    @StateObject private var player = AudioPlayerManager()
    let audioURL: URL
    
    var body: some View {
      
        VStack(spacing: 20){
            Button(player.isPlaying ? "STOP" : "Play" ){
                if player.isPlaying{
                    player.stopAudio()
                }else {
                    player.play(audioURL: audioURL)
                }
            }
        }
    }
}

#Preview {
     let audioURL = URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/StarWars3.mp3")!
        
    
    AudioPlayerVeiw(audioURL: audioURL)
}
