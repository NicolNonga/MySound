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
    @State private var peakLevel: CGFloat = 0
    @State private var phaseShift: CGFloat = 0

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
        let intensity = max(0.2, min(1.0, level * 1.2))
        let adaptiveTop = topColor.opacity(0.6 + 0.4 * Double(intensity))
        let adaptiveBase = baseColor.opacity(colorScheme == .dark ? 0.85 : 0.9)
        let gradient = LinearGradient(colors: [adaptiveTop, adaptiveBase], startPoint: .top, endPoint: .bottom)

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
            peakLevel = 0
            phaseShift = 0
        }
        .onChange(of: level) { newValue in
            updateBars(with: newValue)
        }
        .onChange(of: reduceMotion) { _ in
            phaseShift = 0
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: barHeights)
    }

    // Calcula a altura de cada barra com leve variação ao redor do nível suavizado
    private func updateBars(with newLevel: CGFloat) {
        // Clamp input
        let input = max(0, min(newLevel, 1))

        // Attack/decay smoothing: ataque mais rápido, queda mais lenta
        let attack: CGFloat = max(0.05, 1 - smoothing) // quanto menor smoothing, mais rápido
        let decay: CGFloat = max(0.02, smoothing * 0.5)
        if input > smoothedLevel {
            smoothedLevel = smoothedLevel + (input - smoothedLevel) * attack
        } else {
            smoothedLevel = smoothedLevel + (input - smoothedLevel) * decay
        }

        // Atualiza pico com queda gradual
        if smoothedLevel > peakLevel {
            peakLevel = smoothedLevel
        } else {
            peakLevel = max(0, peakLevel - 0.02) // queda do pico
        }

        // Base height mínima para não sumir
        let base = max(2, smoothedLevel * maxHeight)

        // Atualiza deslocamento de fase para movimento orgânico quando há sinal
        if !reduceMotion {
            let motion = CGFloat(0.6) * (0.3 + 0.7 * smoothedLevel) // mais movimento com mais nível
            phaseShift = (phaseShift + motion).truncatingRemainder(dividingBy: .pi * 2)
        }

        // Distribui variação com fase animada e leve influência do pico
        barHeights = (0..<barCount).map { idx in
            let t = CGFloat(idx) / CGFloat(max(barCount - 1, 1))
            // Forma de onda entre 0.6...1.0
            let wave = (sin(t * .pi + phaseShift) * 0.2 + 0.8)
            // Mistura com pico para dar impressão de energia
            let energy = max(wave, 0.6) * (0.8 + 0.2 * (peakLevel > 0 ? (peakLevel / max(0.001, smoothedLevel + 0.001)) : 0))
            return max(2, base * energy)
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
