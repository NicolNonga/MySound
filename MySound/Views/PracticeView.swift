//
//  ChapterView.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import SwiftUI
import Combine

struct ChapterView: View {
    @StateObject private var ttsService = TTSService()
    @StateObject private var recordingService = RecordingService()
    @StateObject private var viewModel: ChapterViewModel
    
    @State var isRecording = true
    @State var isPaused = false
    
    @State var isPlayMyAudio = false
    
    @State var currentTime: TimeInterval = 0
    @State private var isActive: Bool =  true
    @State private var didAttachTTS = false
    
    @State private var lastScrolledIndex: Int = 0
    
    init(languageCode: String, context: String){
        let text = context
        let vm = ChapterViewModel(chapterText: text, languageCode: languageCode)
        _viewModel = StateObject(wrappedValue: vm)
        // Do not touch ttsService here; it isn't installed yet.
    }
    
    var body: some View {
        ZStack {
            // Conteúdo principal com auto-scroll
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView {
                        HStack {
                            Spacer(minLength: 0)
                            Text(buildAttributedString(words: viewModel.words, highlightIndex: viewModel.currentWordIndex))
                                .font(.title3)
                                .frame(maxWidth: 640, alignment: .leading)
                                .padding()
                                .id("paragraph")
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom)
                    .onChange(of: viewModel.currentWordIndex) { newValue in
                        // Evita rolar imediatamente no início
                        if lastScrolledIndex == 0 && newValue < 5 { return }

                        let visibleHeight = geo.size.height
                        #if canImport(UIKit)
                        let lineHeight = UIFont.preferredFont(forTextStyle: .title3).lineHeight
                        #else
                        let lineHeight: CGFloat = 22
                        #endif

                        // Estimativa heurística de palavras por tela
                        let wordsPerLine = max(6, Int(640 / 10))
                        let linesPerScreen = max(3, Int(visibleHeight / max(lineHeight, 1)))
                        let wordsPerScreen = max(20, wordsPerLine * linesPerScreen / 2)

                        // Limiar: 50% da tela
                        let threshold = max(10, Int(Double(wordsPerScreen) * 0.5))

                        if newValue - lastScrolledIndex >= threshold {
                            withAnimation {
                                proxy.scrollTo("paragraph", anchor: .top)
                            }
                            lastScrolledIndex = newValue
                        }
                    }
                }
            }
            
            // Rodapé: apenas controles agora
            VStack(spacing: 8) {
                Spacer()
                
                if recordingService.isRecording {
                    RecordingBottomBar(
                        isRecording: $isRecording,
                        isPaused: $isPaused,
                        currentTime: $currentTime,
                        currentLevel: CGFloat(recordingService.currentLevel),
                        isActive: $isActive,
                        recordingService: recordingService,
                        chapterViewModel: viewModel
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if !isPlayMyAudio {
                    RecordStartView(
                        ttsService: ttsService,
                        viewModel: viewModel,
                        recordingService: recordingService
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 8) {
            if recordingService.recordingStopped,
               let url = recordingService.fileURL {

                AudioPlayerVeiw(audioURL: url, isPlayMyAudio:  $isPlayMyAudio)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            if !didAttachTTS {
                ttsService.attachWiewModel(viewModel)
                didAttachTTS = true
            }
        }
        
    }
    
    // Cria um AttributedString com destaque amarelo na palavra atual
    // Note: words come from viewModel.words (tokenized by the ViewModel).
    // We intentionally do not split by characters here to avoid robotic highlighting.
    private func buildAttributedString(words: [String], highlightIndex: Int) -> AttributedString {
        var result = AttributedString()
        for (i, w) in words.enumerated() {
            var piece = AttributedString(w)
            piece.font = .system(.title3)
            if i == highlightIndex {
                piece.backgroundColor = .yellow
            }
            result += piece
            if i < words.count - 1 {
                result += AttributedString(" ")
            }
        }
        return result
    }
    
//    private func highlightWord(_ word: String) -> AttributedString {
//        var a = AttributedString(word)
//        a.backgroundColor = .yellow
//        a.font = .system(.title3)
//        return a
//    }

}

#Preview {
    ChapterView(languageCode: "en-GB", context: "Text not available")
}

