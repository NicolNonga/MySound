//
//  CelebrationView.swift
//  MySound
//
//  Created by apple on 2/17/26.
//

import SwiftUI

struct CelebrationView: View {
    @Binding var trigger: Bool
    @State private var animate = false
    @State private var randomOffsets: [(x: CGFloat, y: CGFloat)] = Array(repeating: (x: 0, y: 0), count: 15)

    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                    .offset(x: animate ? randomOffsets[i].x : 0,
                            y: animate ? randomOffsets[i].y : 0)
                    .opacity(animate ? 0 : 1)
            }
        }
        .onChange(of: trigger) { newValue in
            if newValue {
                play()
                // reset the trigger so future toggles can retrigger
                DispatchQueue.main.async {
                    trigger = false
                }
            }
        }
        .onAppear {
            // Do not auto-play on appear; wait for trigger if desired.
        }
    }

    private func play() {
        // Reset to initial state
        animate = false
        // Prepare new random offsets for this run
        randomOffsets = (0..<15).map { _ in
            let x = CGFloat.random(in: -100...100)
            let y = CGFloat.random(in: -150...(-50))
            return (x: x, y: y)
        }
        // Kick off the animation
        withAnimation(.easeOut(duration: 1.0)) {
            animate = true
        }
        // Reset back after the animation completes so it can replay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            animate = false
        }
    }
}

#Preview {
    CelebrationView(trigger: .constant(false))
}
