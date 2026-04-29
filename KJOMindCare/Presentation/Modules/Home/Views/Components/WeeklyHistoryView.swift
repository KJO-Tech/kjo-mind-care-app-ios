import SwiftUI

struct WeeklyHistoryView: View {
    @StateObject private var viewModel = DIContainer.shared.container.resolve(
        WeeklyHistoryViewModel.self)!

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 8) {
                Text(String(localized: "Your Week"))
                    .font(.theme.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            // Content
            if viewModel.isLoading {
                loadingView
            } else if viewModel.errorMessage != nil {
                errorView
            } else {
                historyScrollView
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    private var loadingView: some View {
        HStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 120)  // Adjust height as needed
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var errorView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(String(localized: "Error loading history"))
                .font(.caption)
                .foregroundColor(.red)
            Spacer()
            Button(action: viewModel.loadData) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(Color.theme.primary)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }

    private var historyScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.weeklyHistory) { entry in
                    VStack(spacing: 8) {
                        // Day Initial
                        Text(entry.day.prefix(1))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)

                        // Icon Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    entry.mood.map { Color(hex: $0.color) } ?? Color(hex: "#ebedf0")
                                )
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                .frame(height: 60)

                            if let mood = entry.mood {
                                AsyncImage(url: URL(string: mood.image)) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFit()
                                    } else {
                                        Color.clear  // Wait for load
                                    }
                                }
                                .frame(width: 30, height: 30)
                            } else {
                                AsyncImage(
                                    url: URL(
                                        string:
                                            "https://d14ti7ztt9zv5f.cloudfront.net/emojis/Apple/Ghost-on-Apple-iOS-13.3/Ghost-on-Apple-iOS-13.3.png"
                                    )
                                ) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFit()
                                    } else {
                                        Image(systemName: "nosign")  // Fallback if network fails
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                }
                                .frame(width: 30, height: 30)
                            }
                        }
                        .frame(width: 55)

                        // Horizontal Value Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)

                                if let mood = entry.mood {
                                    Capsule()
                                        .fill(Color(hex: mood.color))
                                        .frame(
                                            width: geometry.size.width
                                                * (CGFloat(mood.value) / 10.0), height: 6)
                                }
                            }
                        }
                        .frame(width: 55, height: 6)
                    }
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
        }
    }
}
