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
    @State private var isPronunciationCorrect: Bool? = true
    
    init(languageCode: String, words: [String]){
       
        let vm = ChapterViewModel(words: words, languageCode: languageCode)
        _viewModel = StateObject(wrappedValue: vm)
        // Do not touch ttsService here; it isn't installed yet.
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 16) {
                Spacer(minLength: 0)

                // Tinder-like Card with centered current word (no controls inside)
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.2), radius: 18, x: 0, y: 10)
                    VStack(spacing: 12) {
                     
                        Text(viewModel.currentWord)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(.primary)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        // Pronunciation result indicator (appears when not nil)
                        if let correct = isPronunciationCorrect {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(correct ? Color.green : Color.red)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: correct ? "checkmark" : "xmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                }
//                                Text(correct ? "Correct" : "Wrong")
//                                    .font(.headline)
//                                    .foregroundStyle(.primary)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .frame(maxWidth: 640)
                .aspectRatio(3/4, contentMode: .fit)
                .padding(.horizontal, 16)

                // Buttons below the card
                HStack(spacing: 20) {
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
                            recordingService: recordingService,
                            showAsHeader: true
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    

}

#Preview {
    ChapterView(languageCode: "en-GB", words: ["Sister", "Father","Son" ])
}

