//
//  RecordingBottomBar.swift
//  MySound
//
//  Created by apple on 12/12/25.
//

import SwiftUI

struct RecordingBottomBar: View {

    @Binding var isRecording: Bool
    @Binding var isPaused: Bool
    @Binding var currentTime: TimeInterval
    var currentLevel: CGFloat
    @Binding var isActive: Bool
    @StateObject var recordingService: RecordingService

    
    // Novo: controla se é usado no topo
    var showAsHeader: Bool = false
    @StateObject var chapterViewModel: ChapterViewModel
    
    var body: some View {
        VStack {
            if !showAsHeader { Spacer() }
            
            
            HStack(spacing: 16) {
                Text(formatTime(currentTime))
                    .font(.system(size: 20, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                
                WaveformView.whatsAppCompact(level: currentLevel, color: .blue, maxHeight: 28)
                    .padding(.horizontal, 12)
                
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.gray.opacity(0.35)))
                }
                
                
                Button {
                    isRecording = false
                    recordingService.stopRecording()
                    // Para o avanço automático quando parar a gravação
                    // Como este componente não tem acesso direto ao viewModel,
                    // pare o avanço no lugar onde o stop é acionado, ou injete o viewModel aqui.
                    // Se preferir parar aqui, precisamos receber o viewModel como parâmetro.
            
                    chapterViewModel.reset()
                    chapterViewModel.stopAutoAdvance()
                    
                    
                    
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.red))
                }
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
            .padding(.bottom, showAsHeader ? 0 : 12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: isRecording)
        }
    }
    
    func formatTime(_ t: TimeInterval) -> String {
        let minutes = Int(t) / 60
        let seconds = Int(t) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct RecordingBottomBar_Previews: PreviewProvider {


    struct PreviewWrapper: View {
        @State var isRecording = true
        @State var isPaused = false
        @State var currentTime: TimeInterval = 0
        var currentLevel: CGFloat = 0.5
        @State var isActive: Bool = false
 

            
        
        var body: some View {
            let sampleText: [String: String] = [
                "en-GB": "This is a simple sample chapter. The user will read this text aloud.",
                "fr-FR": "Ceci est un chapitre exemple simple. L'utilisateur lira ce texte à voix haute.",
                "es-ES": "Este es un capítulo de exemplo simple. El usuario leerá este texto en voz alta.",
                "pt-BR": "Este é um capítulo de exemplo simples. O usuário lerá este texto en voz alta."
            ]
            let text = sampleText["en-GB"] ?? "Text not available"
            let chapterViewModel: ChapterViewModel = ChapterViewModel(chapterText: text, languageCode: "en-GB")
            
            let recordingService: RecordingService = RecordingService()
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                RecordingBottomBar(
                    isRecording: $isRecording,
                    isPaused: $isPaused,
                    currentTime: $currentTime,
                    currentLevel: currentLevel,
                    isActive: $isActive,
                    recordingService: recordingService,
                    showAsHeader: true,
                    chapterViewModel: chapterViewModel
                )
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.light)
        
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}

