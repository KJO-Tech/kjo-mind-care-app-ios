import AVKit
import SwiftUI
import YouTubePlayerKit

struct ExerciseDetailView: View {
    @StateObject var viewModel: ExerciseDetailViewModel
    var onBack: (() -> Void)? = nil
    var onComplete: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
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

                            // Content Switch
                            switch exercise.contentType {
                            case .TEXT, .AUDIO:
                                VStack(alignment: .leading, spacing: 16) {
                                    // Thumbnail for Text/Audio if available
                                    if let thumbUrl = exercise.thumbnailUrl,
                                        let url = URL(string: thumbUrl)
                                    {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxHeight: 200)
                                                .cornerRadius(12)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                                .frame(maxWidth: .infinity, minHeight: 150)
                                                .background(Color.theme.surface)
                                                .cornerRadius(12)
                                        }
                                    }

                                    Text(exercise.getContentText())
                                        .font(.theme.body)
                                        .foregroundColor(Color.theme.textSecondary)
                                        .lineSpacing(6)
                                }

                            case .VIDEO:
                                VStack(spacing: 16) {
                                    if exercise.contentUrl.contains("youtube.com")
                                        || exercise.contentUrl.contains("youtu.be")
                                    {
                                        // YouTube Player
                                        YouTubePlayerView(
                                            YouTubePlayer(urlString: exercise.contentUrl)
                                        )
                                        .frame(height: 220)
                                        .cornerRadius(12)
                                    } else if let url = URL(string: exercise.contentUrl) {
                                        // Native Video Player
                                        VideoPlayer(player: AVPlayer(url: url))
                                            .frame(height: 220)
                                            .cornerRadius(12)
                                    } else {
                                        Text("Invalid Video URL")
                                            .foregroundColor(.red)
                                    }

                                    // Instructions for video context if any
                                    if !exercise.getContentText().isEmpty {
                                        Text(exercise.getContentText())
                                            .font(.theme.body)
                                            .foregroundColor(Color.theme.textSecondary)
                                            .lineSpacing(6)
                                    }
                                }

                            default:
                                Text("Content type not supported yet.")
                                    .font(.theme.caption)
                                    .foregroundColor(Color.theme.textSecondary)
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
//        .navigationTitle(viewModel.exercise?.getTitle() ?? "Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            // Floating Complete Button
            Button(action: {
                viewModel.completeExercise()
                // Call onComplete callback after a short delay to allow UI to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete?()
                }
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
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}
