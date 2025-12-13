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
    @Binding var isPlayMyAudio: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ouvir meu audio")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text( player.isPlaying ? "Ouvindo..." :"clica no play pra ouvir ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                isPlayMyAudio.toggle()
                if player.isPlaying {
                    player.stopAudio()
                }else {
                    player.play(audioURL: audioURL)
                }
            } label: {
                Image(systemName: !player.isPlaying ? "play.fill" : "stop.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.blue))
            }
            .accessibilityLabel("Listen")
            .accessibilityHint("Start reading the chapter aloud.")
            

        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 10)
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    
    }
}
        
//
//        VStack(spacing: 20){
//            Button(player.isPlaying ? "STOP" : "Play" ){
//                if player.isPlaying{
//                    player.stopAudio()
//                }else {
//                    player.play(audioURL: audioURL)
//                }
//            }
//        }
    


#Preview {
    @Previewable @State var playMyAudio = false
    let audioURL = URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/StarWars3.mp3")!
    
    AudioPlayerVeiw(audioURL: audioURL, isPlayMyAudio: $playMyAudio)

    

}
