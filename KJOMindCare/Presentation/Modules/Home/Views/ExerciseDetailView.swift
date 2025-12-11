import AVKit
import SwiftUI

struct ExerciseDetailView: View {
    @StateObject var viewModel: ExerciseDetailViewModel
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header with Back Button
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.theme.text)
                        .padding(12)
                        .background(Color.theme.background)
                        .clipShape(Circle())
                        .shadow(color: Color.theme.shadow.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.leading, 16)
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color.theme.background)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if let exercise = viewModel.exercise {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title and Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.getTitle())
                                .font(.theme.title)
                                .foregroundColor(Color.theme.text)

                            Text(exercise.getDescription())
                                .font(.theme.body)
                                .foregroundColor(Color.theme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 24)

                        // Metadata (Duration, Difficulty)
                        HStack(spacing: 16) {
                            Label(
                                title: { Text("\(exercise.durationMinutes) min") },
                                icon: { Image(systemName: "clock") }
                            )
                            .font(.theme.subheadline)
                            .foregroundColor(Color.theme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.theme.primary.opacity(0.1))
                            .cornerRadius(8)

                            Label(
                                title: { Text(exercise.difficulty.rawValue.capitalized) },
                                icon: { Image(systemName: "chart.bar.fill") }
                            )
                            .font(.theme.subheadline)
                            .foregroundColor(Color.theme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.theme.primary.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)

                        // Content Area
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.theme.headline)
                                .foregroundColor(Color.theme.text)

                            if exercise.contentType == .TEXT {
                                Text(exercise.getContentText())
                                    .font(.theme.body)
                                    .foregroundColor(Color.theme.textSecondary)
                                    .lineSpacing(6)
                            } else {
                                // Placeholder for multimedia
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.black.opacity(0.8))
                                        .aspectRatio(16 / 9, contentMode: .fit)

                                    VStack(spacing: 12) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(.white)

                                        Text("Multimedia Content Placeholder")
                                            .foregroundColor(.white)
                                            .font(.theme.caption)
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(Color.theme.surface)  // Assuming surface is checking card or similar
                        .cornerRadius(24)
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 100)
                }
            } else {
                Text("Exercise not found")
                    .font(.theme.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .frame(maxHeight: .infinity)
            }
        }
        .background(Color.theme.background)
        .overlay(alignment: .bottom) {
            // Floating Complete Button
            Button(action: {
                viewModel.completeExercise()
            }) {
                HStack {
                    Text(viewModel.isCompleted ? "Completed" : "Complete Exercise")
                        .font(.theme.headline)
                        .fontWeight(.bold)

                    if viewModel.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(viewModel.isCompleted ? Color.theme.success : Color.theme.primary)
                .cornerRadius(16)
                .shadow(
                    color: (viewModel.isCompleted ? Color.theme.success : Color.theme.primary)
                        .opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(viewModel.isCompleted)
            .padding(24)
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}
