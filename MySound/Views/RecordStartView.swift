//
//  RecordStartView.swift
//  MySound
//
//  Created by apple on 12/12/25.
//

import SwiftUI
import Combine

struct RecordStartView: View {
    @StateObject  var ttsService: TTSService
    @StateObject var viewModel: ChapterViewModel
    @StateObject var recordingService: RecordingService
    
    // Novo: quando usado como header, não usa Spacer superior
    var showAsHeader: Bool = false
    
    @State private var isRecording: Bool = false
    @State private var isPaused: Bool = false
    @State private var currentTime: TimeInterval = 12
    @State private var isActive: Bool = true
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {
            if !showAsHeader { Spacer() }

            HStack(spacing: 16) {
                // Only buttons: play/stop and mic
                if !ttsService.isSpeaking && !recordingService.isRecording {
                    Button {
                        ttsService.speak(viewModel.currentWord, languageCode: viewModel.languageCode)

                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.blue))
                    }
                    .accessibilityLabel("Listen")
                    .accessibilityHint("Start reading the chapter aloud.")
                } else {
                    Button {
                        ttsService.stop()
                        viewModel.stopAutoAdvance()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.red))
                    }
                    .accessibilityLabel("Stop")
                    .accessibilityHint("Stop the speech.")
                }

                Button {
                    Task {
                        if ttsService.isSpeaking { ttsService.stop() }
                        await recordingService.startRecording()
                        // Inicia avanço automático durante a gravação a cada 0.8s

                        isRecording = true
                    }
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.red))
                }
                .disabled(recordingService.isRecording)
                .opacity(recordingService.isRecording ? 0.5 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))

            if !showAsHeader {
                Spacer().frame(height: 8).padding(.bottom, 12)
            }
        }
        .task {
            while true {
                try? await Task.sleep(for: .seconds(1))
                currentTime += 1
                print("TASK TICK")
            }
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
    let text = ["Mother", "Father", "Sister", "Brother"]
    let recordingService = RecordingService()
    let _viewModel = ChapterViewModel(words: text, languageCode: "en-GB")
    RecordStartView(ttsService: ts, viewModel: _viewModel, recordingService: recordingService, showAsHeader: true)
}

