//
//  RecordStartView.swift
//  MySound
//
//  Created by apple on 12/12/25.
//

import SwiftUI

struct SpeakTextView: View {
    @StateObject  var ttsService:TTSService
    @StateObject var viewModel: ChapterViewModel
    
    var body: some View {
        if !ttsService.isSpeaking  {
            Button(action: {
                ttsService.speak(viewModel.chapterText, languageCode: viewModel.languageCode)
            }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(20)
            .accessibilityLabel("Listen")
            .accessibilityHint("Start reading the chapter aloud.")


        }else {
            Button(action: {
                ttsService.stop()
            }) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(20)
            .accessibilityLabel("Stop")
            .accessibilityHint("Stop the speech.")
        }


    }
}

#Preview {
    let ts = TTSService()
    
    let sampleText: [String: String] = [
        "en-GB": "This is a simple sample chapter. The user will read this text aloud.",
        "fr-FR": "Ceci est un chapitre exemple simple. L'utilisateur lira ce texte à voix haute.",
        "es-ES": "Este es un capítulo de exemplo simple. El usuario leerá este texto en voz alta.",
        "pt-BR": "Este é um capítulo de exemplo simples. O usuário lerá este texto en voz alta."
    ]

    let text = ["Mother", "Father"]
    
     var _viewModel = ChapterViewModel(words: text, languageCode: "en-GB")
    SpeakTextView(ttsService: ts, viewModel: _viewModel)
}
