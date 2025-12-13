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
        
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: []) {
                    ForEach(viewModel.languages) { language in
                        NavigationLink(destination: ChapterView(languageCode: language.code)) {
                            HStack(spacing: 12) {
                                // Red circular "flag" placeholder
                                ZStack {
                                    Circle()
                                        .fill(language.color)
                                        .frame(width: 44, height: 44)
                                    Text(language.firstLatterName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                 
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(language.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(language.code)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }

                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Select Language")
        }
       
    }
}

#Preview {
    LanguageListView()
}
