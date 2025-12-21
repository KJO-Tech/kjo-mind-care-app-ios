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

            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {

                headerSection

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {

                        Text(String(localized: "How are you feeling?"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

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
    }
}

extension RecordMoodView {

    fileprivate var headerSection: some View {
        HStack {
            Text(String(localized: "Mood Tracker"))
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
    }

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
            Text("Add a note (optional)")
                .font(.headline)
                .foregroundColor(.white)

            ZStack(alignment: .topLeading) {
                if viewModel.noteText.isEmpty {
                    Text("How are you feeling today? What's on your mind?")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $viewModel.noteText)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }

    fileprivate var actionButtonsSection: some View {
        VStack {
            Spacer()
            
            // Success/Error Messages
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
            }
            
            HStack(spacing: 15) {

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(15)
                }
                .disabled(viewModel.isSaving)
                
                Button(action: {
                    viewModel.saveMood()
                    // Dismiss after a short delay if successful
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if viewModel.successMessage != nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(viewModel.isSaving ? "Saving..." : String(localized: "Guardar"))
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isSaving ? Color.gray : Color.teal)
                    .cornerRadius(15)
                }
                .disabled(viewModel.isSaving || viewModel.selectedMood == nil)
            }
            .padding(20)
            .background(Color.black.opacity(0.8))
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
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(mood.description["es"] ?? mood.description["en"] ?? "")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.2))
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
