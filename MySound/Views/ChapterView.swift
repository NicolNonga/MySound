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
    @State var currentTime: TimeInterval = 0
    @State private var isActive: Bool =  true
    @State private var didAttachTTS = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var words: [String] {
        viewModel.chapterText.components(separatedBy: "")
    }
    
    init(languageCode: String){
        let sampleText: [String: String] = [
            "en-GB":
"""
Chapter 1: A Quiet Beginning

The morning light crept through the curtains, tracing pale lines across the wooden floor. In the stillness, the house seemed to hold its breath, as if waiting for a whisper to stir the day awake. At the kitchen table, a half-open book rested beside a steaming mug of tea, its pages marked with notes and small circles around words that mattered.

Outside, the street was gentle—footsteps here, a bicycle bell there, the soft rustle of leaves in a passing breeze. It was the kind of morning that made promises without saying a word, the kind that felt like a clean page waiting to be written on. She took a slow breath, closed her eyes, and listened. There it was again: the quiet rhythm of a new day, steady and unhurried.

She reached for the book, turned a page, and smiled. Today would be different—not louder, not brighter, but clearer. There were things to learn, things to say out loud, and things to finally let go of. And for the first time in a long time, that felt enough.
""",
            "fr-FR":
"""
Chapitre 1 : Un début tranquille

La lumière du matin glissait entre les rideaux, dessinant des lignes pâles sur le parquet. Dans le silence, la maison semblait retenir son souffle, comme si elle attendait qu’un murmure vienne réveiller le jour. Sur la table de la cuisine, un livre entrouvert reposait à côté d’une tasse de thé fumante, ses pages annotées de petites notes et de cercles autour des mots importants.

Dehors, la rue était douce — quelques pas, une sonnette de vélo, le léger bruissement des feuilles dans une brise passante. C’était le genre de matin qui fait des promesses sans prononcer un mot, celui qui ressemble à une page blanche prête à être écrite. Elle inspira lentement, ferma les yeux et écouta. Il était là, encore : le rythme discret d’un nouveau jour, stable et sans hâte.

Elle saisit le livre, tourna une page et sourit. Aujourd’hui serait différent — pas mais mais mais mais mais mais mais mais mais mais mais mais mais mais mais plus clair. Il y avait des choses à apprendre, des mots à dire à voix haute, et d’autres à laisser partir. Et pour la première fois depuis longtemps, c’était suffisant.
""",
            "es-ES":
"""
Capítulo 1: Un comienzo silencioso

La luz de la mañana se colaba por las cortinas, dibujando líneas pálidas sobre el suelo de madera. En el silencio, la casa parecía contener la respiración, como si esperara que un susurro despertara el día. En la mesa de la cocina, un libro entreabierto descansaba junto a una taza de té humeante, con páginas marcadas por notas y pequeños círculos alrededor de palabras que importaban.

Afuera, la calle era serena: pasos por aquí, el timbre de una bicicleta por allá, el suave susurro de las hojas con la brisa. Era ese tipo de mañana que hace promesas sin decir nada, el tipo que se siente como una página en blanco esperando ser escrita. Respiró despacio, cerró los ojos y escuchó. Allí estaba de nuevo: el ritmo callado de un nuevo día, constante y sin prisa.

Tomó el libro, pasó una página y sonrió. Hoy sería distinto — no más ruidoso, no más brillante, pero sí más claro. Había cosas que aprender, cosas que decir en voz alta y cosas que, por fin, dejar ir. Y por primera vez en mucho tiempo, eso bastaba.
""",
            "pt-BR":
"""
Capítulo 1: Um começo tranquilo

A luz da manhã atravessava as cortinas, traçando linhas pálidas sobre o piso de madeira. No silêncio, a casa parecia prender a respiração, como se esperasse que um sussurro despertasse o dia. Sobre a mesa da cozinha, um livro entreaberto repousava ao lado de uma caneca de chá fumegante, com páginas marcadas por anotações e pequenos círculos em torno de palavras importantes.

Lá fora, a rua era mansa — passos acolá, a campainha de uma bicicleta acolá, o leve farfalhar das folhas numa brisa passageira. Era o tipo de manhã que faz promessas sem dizer nada, o tipo que se parece com uma página em branco esperando para ser escrita. Ela inspirou devagar, fechou os olhos e escutou. Lá estava de novo: o ritmo silencioso de um novo dia, constante e sem pressa.

Pegou o livro, virou a página e sorriu. Hoje seria diferente — não mais barulhento, não mais brilhante, mas mais nítido. Havia coisas para aprender, coisas para dizer em voz alta e coisas para, enfim, deixar ir. E, pela primeira vez em muito tempo, isso era o bastante.
"""
        ]
        let text = sampleText[languageCode] ?? "Text not available"
        let vm = ChapterViewModel(chapterText: text, languageCode: languageCode)
        _viewModel = StateObject(wrappedValue: vm)
        // Do not touch ttsService here; it isn't installed yet.
    }
    
    var body: some View {
        ZStack {
            // Conteúdo principal
            ScrollView {
                HighlightedTextView(words: viewModel.words, currentWordIndex: viewModel.currentWordIndex)
                    .padding(.horizontal, 12)
                    // Reserva espaço suficiente para player + card inferior
                    .padding(.bottom, bottomReservedSpace)
            }
            
            // Rodapé: Player acima, card de ação abaixo
            VStack(spacing: 8) {
                Spacer()
                
                if recordingService.recordingStopped, let url = recordingService.fileURL {
                    // Player com a mesma "casca" de card clean
                    playerCard {
                        AudioPlayerVeiw(audioURL: url)
                    }
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if recordingService.isRecording {
                    RecordingBottomBar(
                        isRecording: $isRecording,
                        isPaused: $isPaused,
                        currentTime: $currentTime,
                        currentLevel: CGFloat(recordingService.currentLevel),
                        isActive: $isActive,
                        recordingService: recordingService
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    RecordStartView(
                        ttsService: ttsService,
                        viewModel: viewModel,
                        recordingService: recordingService
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onReceive(timer){ _ in
            if recordingService.isRecording {
                currentTime += 1
                viewModel.startAutoAdvance(interval: 0.8)
            }
        }
        .onAppear {
            if !didAttachTTS {
                ttsService.attachWiewModel(viewModel)
                didAttachTTS = true
            }
        }
        .onDisappear {
            ttsService.stop()
            if recordingService.isRecording { recordingService.stopRecording() }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // Espaço reservado no final do ScrollView para não cobrir o texto
    private var bottomReservedSpace: CGFloat {
        // Alturas aproximadas: player + card
        let playerHeight: CGFloat = recordingService.recordingStopped ? 120 : 0
        let cardHeight: CGFloat = recordingService.isRecording ? 140 : 120
        return playerHeight + cardHeight + 24
    }
    
    // Wrapper reutilizável com o mesmo estilo do "card clean"
    @ViewBuilder
    private func playerCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
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
    }
}

#Preview {
    ChapterView(languageCode: "en-GB")
}
