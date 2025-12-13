//
//  HighLightedTextView.swift
//  MySound
//
//  Created by apple on 12/12/25.
//

import SwiftUI

struct HighlightedTextView: View {
    let words: [String]
    let currentWordIndex: Int
    
    var body: some View {
        WrapHStack(words: words, currentWordIndex: currentWordIndex)
            .padding()
    }
}

#Preview {
    HighlightedTextView(
        words: ["This", "is", "a", "sample", "text", "for", "preview."],
        currentWordIndex: 0
    )
}


struct WrapHStack: View {
    let words: [String]
    let currentWordIndex: Int
    
    var body: some View {
        // Usamos VStack com linhas automáticas
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(Array(words.enumerated()), id: \.0) { index, word in
                    Text(word)
                        .font(.title3)
                        .padding(4)
                        .background(index == currentWordIndex ? Color.yellow : Color.clear)
                        .cornerRadius(4)
                        .foregroundColor(.primary)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geo.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if index == words.count - 1 {
                                width = 0
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if index == words.count - 1 {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}









