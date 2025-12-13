//
//  LanguageListView.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import SwiftUI

struct LanguageListView: View {
    @StateObject var viewModel = LanguageListViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.languages) { language in
                        NavigationLink(value: language) {
                            languageRow(language)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Select Language")
            .navigationDestination(for: Language.self) { lang in
                ChapterView(languageCode: lang.code)
            }
        }
    }
    
    @ViewBuilder
    private func languageRow(_ language: Language) -> some View {
        HStack(spacing: 12) {
            // Ícone/flag com gradiente e aro
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                language.color.opacity(0.95),
                                language.color.opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                Text(language.firstLatterName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(language.name)
                    .font(.system(.headline, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(language.code)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
        )
    }
}

#Preview {
    LanguageListView()
}

