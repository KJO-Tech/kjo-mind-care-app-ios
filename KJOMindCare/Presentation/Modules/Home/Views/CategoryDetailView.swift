import SwiftUI

struct CategoryDetailView: View {
    @StateObject var viewModel: CategoryDetailViewModel
    var onBack: (() -> Void)? = nil
    let onExerciseSelected: (String) -> Void  // Pass ID

    // Grid layout: 2 columns
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.exercises) { exercise in
                            CategoryExerciseCard(exercise: exercise) {
                                onExerciseSelected(exercise.id ?? "")
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color.theme.background)
        .navigationTitle(viewModel.category?.getName() ?? "Category")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}

struct CategoryExerciseCard: View {
    let exercise: DailyExercise
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(exercise.getTitle())
                .font(.theme.headline)
                .foregroundColor(Color.theme.text)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Description
            Text(exercise.getDescription())
                .font(.theme.caption)
                .foregroundColor(Color.theme.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            // Metadata Row: Duration & Difficulty
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("\(exercise.durationMinutes) min")
                        .font(.theme.caption)
                }
                .foregroundColor(Color.theme.primary)

                Spacer()

                Text(exercise.difficulty.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.theme.surface)
                    .cornerRadius(8)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .padding(16)
        .frame(minHeight: 140)  // Give it some height consistency
        .background(Color.theme.card)
        .cornerRadius(16)
        .shadow(color: Color.theme.shadow.opacity(0.05), radius: 6, x: 0, y: 3)
        .onTapGesture {
            onTap()
        }
    }
}
