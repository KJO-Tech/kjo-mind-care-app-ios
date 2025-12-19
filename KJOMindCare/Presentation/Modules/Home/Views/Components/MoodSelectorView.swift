import SwiftUI

struct MoodSelectorView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var coordinator: HomeCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            // Header
            HStack(spacing: 12) {
                Text(String(localized: "How are you feeling?"))
                    .font(.theme.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            // Content
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error: error)
            } else if viewModel.moods.isEmpty {
                emptyView
            } else {
                moodsScrollView
            }

            // Register Button
            registerButton
        }
        .padding(.vertical)
        //.background(Color.theme.surface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private var loadingView: some View {
        HStack {
            ForEach(0..<5) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 80)
            }
        }
    }

    private func errorView(error: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                Text(String(localized: "Error loading moods"))
                    .foregroundColor(.red)
            }
            Button(action: {
                viewModel.fetchMoods()
            }) {
                Label(String(localized: "Retry"), systemImage: "arrow.clockwise")
                    .font(.caption)
                    .foregroundColor(.theme.primary)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }

    private var emptyView: some View {
        Text(String(localized: "No moods available"))
            .foregroundColor(.gray)
            .padding()
    }

    private var moodsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.moods) { mood in
                    Button(action: {
                        withAnimation {
                            viewModel.selectMood(id: mood.id)
                        }
                    }) {
                        moodItem(mood: mood)
                    }
                }
            }
            .padding(.vertical, 5)
        }
    }

    private func moodItem(mood: Mood) -> some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: mood.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "face.smiling")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            Text(mood.name["es"] ?? mood.name["en"] ?? "")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.primaryContent)
                .lineLimit(1)
        }
        .padding()
        .frame(width: 80, height: 90)
        .background(Color(hex: mood.color))
        .cornerRadius(12)
        .opacity(
            viewModel.selectedMoodId == mood.id
                ? 1.0 : (viewModel.selectedMoodId == nil ? 1.0 : 0.5)
        )
        .scaleEffect(viewModel.selectedMoodId == mood.id ? 1.1 : 1.0)
        .shadow(radius: viewModel.selectedMoodId == mood.id ? 4 : 2)
    }

    private var registerButton: some View {
        Button(action: {
            coordinator.showRecordMood(moodId: viewModel.selectedMoodId)
        }) {
            Label(String(localized: "Log Mood"), systemImage: "plus")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.theme.primary, Color.theme.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(radius: 5)
        }
    }
}
