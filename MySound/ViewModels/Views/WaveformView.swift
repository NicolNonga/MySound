//
//  WaveformView.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import SwiftUI

struct WaveformView: View {
    // Entrada de nível normalizado (0...1)
    var level: CGFloat

    // Aparência
    var barCount: Int
    var barWidth: CGFloat
    var spacing: CGFloat
    var cornerRadius: CGFloat
    var maxHeight: CGFloat
    var baseColor: Color
    var topColor: Color
    var smoothing: CGFloat   // 0...1 (0 = sem suavização, 1 = muito suave)

    // Estado interno para suavização e alturas
    @State private var smoothedLevel: CGFloat = 0
    @State private var barHeights: [CGFloat] = []

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        level: CGFloat,
        barCount: Int = 7,
        barWidth: CGFloat = 8,
        spacing: CGFloat = 4,
        cornerRadius: CGFloat = 3,
        maxHeight: CGFloat = 28,
        baseColor: Color = .blue.opacity(0.9),
        topColor: Color = .blue,
        smoothing: CGFloat = 0.35
    ) {
        self.level = level
        self.barCount = max(barCount, 3)
        self.barWidth = barWidth
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.maxHeight = maxHeight
        self.baseColor = baseColor
        self.topColor = topColor
        self.smoothing = min(max(smoothing, 0), 0.95)
    }

    var body: some View {
        let gradient = LinearGradient(
            colors: [topColor, baseColor],
            startPoint: .top,
            endPoint: .bottom
        )

        HStack(spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(gradient)
                    .frame(width: barWidth, height: heightForBar(i))
            }
        }
        .onAppear {
            smoothedLevel = 0
            barHeights = Array(repeating: 2, count: barCount)
        }
        .onChange(of: level) { newValue in
            updateBars(with: newValue)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: barHeights)
    }

    // Calcula a altura de cada barra com leve variação ao redor do nível suavizado
    private func updateBars(with newLevel: CGFloat) {
        // Suavização exponencial (EMA)
        smoothedLevel = smoothing * smoothedLevel + (1 - smoothing) * max(0, min(newLevel, 1))

        // Escala de altura (mínimo 2pt para não sumir)
        let base = max(2, smoothedLevel * maxHeight)

        // Distribui variação sutil entre as barras, criando “onda” mais orgânica
        barHeights = (0..<barCount).map { idx in
            let phase = CGFloat(idx) / CGFloat(max(barCount - 1, 1)) * .pi
            let wobble = (sin(phase) * 0.25 + 0.75) // 0.5...1.0 approx
            return max(2, base * wobble)
        }
    }

    private func heightForBar(_ index: Int) -> CGFloat {
        guard barHeights.indices.contains(index) else { return 2 }
        return barHeights[index]
    }
}

// Presets
extension WaveformView {
    // Preset “WhatsApp compacto”
    static func whatsAppCompact(level: CGFloat, color: Color = .blue, maxHeight: CGFloat = 28) -> WaveformView {
        WaveformView(
            level: level,
            barCount: 7,
            barWidth: 8,
            spacing: 4,
            cornerRadius: 3,
            maxHeight: maxHeight,
            baseColor: color.opacity(0.9),
            topColor: color,
            smoothing: 0.35
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        WaveformView.whatsAppCompact(level: 0.1, color: .blue)
        WaveformView.whatsAppCompact(level: 0.5, color: .blue)
        WaveformView.whatsAppCompact(level: 0.9, color: .blue)
    }
    .padding()
    .preferredColorScheme(.dark)
}
