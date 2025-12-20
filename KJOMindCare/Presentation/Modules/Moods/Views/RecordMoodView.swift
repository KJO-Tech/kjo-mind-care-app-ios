//
//  RecordMoodView.swift
//  KJOMindCare
//
//  Created by Raydberg on 24/11/25.
//

import SwiftUI

struct RecordMoodView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = DIContainer.shared.container.resolve(
        RecordMoodViewModel.self)!

    var selectedMoodId: String?  // Pre-selected mood ID

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        Text(String(localized: "mood.record.question"))
                            .font(Font.theme.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.text)

                        moodGridSection

                        noteSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }

            actionButtonsSection
        }
        .onAppear {
            if let moodId = selectedMoodId {
                viewModel.selectMood(byId: moodId)
            }
        }
        .navigationTitle(String(localized: "mood.record.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension RecordMoodView {

    fileprivate var moodGridSection: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(viewModel.moods) { mood in
                MoodCardItem(
                    mood: mood,
                    isSelected: viewModel.selectedMood == mood
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        viewModel.selectMood(mood)
                    }
                }
            }
        }
    }

    fileprivate var noteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "mood.record.note.title"))
                .font(Font.theme.headline)
                .foregroundColor(Color.theme.text)

            ZStack(alignment: .topLeading) {
                if viewModel.noteText.isEmpty {
                    Text(String(localized: "mood.record.note.placeholder"))
                        .foregroundColor(Color.theme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $viewModel.noteText)
                    .padding(8)  // Internal padding
                    .scrollContentBackground(.hidden)
                    .background(Color.theme.card)
                    .foregroundColor(.theme.text)
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.theme.border, lineWidth: 1)
                    )
            }
        }
    }

    fileprivate var actionButtonsSection: some View {
        VStack {
            Spacer()
            HStack(spacing: 15) {

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(String(localized: "common.cancel"))
                        .font(Font.theme.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.text)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(15)
                }
                Button(action: {
                    viewModel.saveMood()
                }) {
                    Text(String(localized: "mood.record.save"))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.primaryContent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.primary)
                        .cornerRadius(15)
                }
            }
            .padding(20)
            .background(Color.theme.background.opacity(0.95))
        }
        .onChange(of: viewModel.isSaved) { isSaved in
            if isSaved {
                presentationMode.wrappedValue.dismiss()
            }
        }
            
        
    }
}

struct MoodCardItem: View {
    let mood: Mood
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: mood.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "face.smiling")  // Fallback
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .shadow(radius: isSelected ? 5 : 0)

            Text(mood.name["es"] ?? mood.name["en"] ?? "")
                .font(Font.theme.headline)
                .foregroundColor(Color.theme.text)
                .multilineTextAlignment(.center)

            Text(mood.description["es"] ?? mood.description["en"] ?? "")
                .font(Font.theme.caption2)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.theme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color(hex: mood.color) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .opacity(isSelected ? 1.0 : 0.6)
    }
}

struct RecordMoodView_Previews: PreviewProvider {
    static var previews: some View {
        RecordMoodView()
    }
}
