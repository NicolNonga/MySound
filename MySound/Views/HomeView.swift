//
//  LanguageListView.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import SwiftUI

struct LanguageListView: View {
    @StateObject var viewModel = HomeViewMode()
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 12){
                ForEach(TextCategory.allCases){ category in
                    Button(action: {
                        viewModel.selectedCategory = category
                    }){
                        Text(category.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedCategory == category ? Color.yellow.opacity(0.4) : Color.gray.opacity(0.15))
                            .cornerRadius(16)
                    }
                    
                }
            }.padding(.horizontal)
                .padding(.top, 8)
        }
        NavigationView {
            List(viewModel.filteredTexts) { text in
                NavigationLink(destination: ChapterView(languageCode: "en-US", words: ["Mother", "Father", "Son"])) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(text.title)
                                .font(.headline)

                            Text(text.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if text.isUnread {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }

                        Button(action: {
                            viewModel.toggleFavorite(text.id)
                        }) {
                            Image(systemName: text.isFavorite ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 6)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.markAsRead(text.id)
                })
            }
            .listStyle(.plain)
        }
        .navigationTitle("Practice Library")
                
        }
    }

#Preview {
     LanguageListView()
}

