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
    @Binding private var currentTime: TimeInterval = 12
    @State private var isActive: Bool = true
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 10) {
            if !showAsHeader { Spacer() }
            
            // CARD CLEAN
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ouvir ou Praticar")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(ttsService.isSpeaking ? "Lendo em voz alta..." :
                         (recordingService.isRecording ? "Gravando..." : "Escolha uma opção"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !ttsService.isSpeaking && !recordingService.isRecording {
                    Button {
                        ttsService.speak(viewModel.chapterText, languageCode: viewModel.languageCode)
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
                        viewModel.startAutoAdvance(interval: 0.8)
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
            
            if !showAsHeader {
                Spacer().frame(height: 8).padding(.bottom, 12)
            }
        }.task {
            while true {
                try? await Task.sleep(for: .seconds(1))
                currentTime += 1
                print("TASK TICK")
            }
        }

        
//            .onReceive(timer) { _ in
//              
//                currentTime += 1
//            }
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
    let text = sampleText["en-GB"] ?? "Text not available"
    let recordingService = RecordingService()
    let _viewModel = ChapterViewModel(chapterText: text, languageCode: "en-GB")
    RecordStartView(ttsService: ts, viewModel: _viewModel, recordingService: recordingService, showAsHeader: true)
}

