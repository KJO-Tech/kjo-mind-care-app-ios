import SwiftUI

struct WeeklyMoodEntry: Identifiable {
    let id = UUID()
    let day: String
    let date: Date
    let mood: Mood?
}

struct WeeklyHistoryView: View {
    @State private var weeklyHistory: [WeeklyMoodEntry] = []
    @State private var isLoading = true
    @State private var hasError = false

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
            if isLoading {
                loadingView
            } else if hasError {
                errorView
            } else {
                historyScrollView
            }
        }
        .onAppear {
            loadMockData()
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
            Button(action: loadMockData) {
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
                ForEach(weeklyHistory) { entry in
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

    // Mock Data Logic
    private func loadMockData() {
        // Simulate network delay
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.weeklyHistory = self.generateCurrentWeekData()
            self.isLoading = false
        }
    }

    private func generateCurrentWeekData() -> [WeeklyMoodEntry] {
        var entries: [WeeklyMoodEntry] = []
        let calendar = Calendar.current
        let today = Date()

        // Find Monday of the current week.
        // weekOfYear determines the week, .weekday == 2 is Monday.

        // We will just generate "This week's Monday to Saturday"
        // Let's get the start of the week relative to today.
        // Assuming Gregorian, Sunday=1, Monday=2.

        let weekday = calendar.component(.weekday, from: today)
        // Calculate days to subtract to get to Monday.
        // If today is Sunday (1), we want previous Monday (-6 days).
        // If today is Monday (2), we want today (0 days).
        // If today is Saturday (7), we want Monday (-5 days).

        var daysToSubtract = 0
        if weekday == 1 {  // Sunday
            daysToSubtract = 6
        } else {
            daysToSubtract = weekday - 2
        }

        guard let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
            return []
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"

        for i in 0...5 {  // Monday (0) to Saturday (5)
            if let date = calendar.date(byAdding: .day, value: i, to: monday) {
                let dayName = dateFormatter.string(from: date).capitalized

                // Random mood or empty
                // Higher chance of empty to show the ghost
                let randomMood = Int.random(in: 0...10) > 4 ? mockMoods.randomElement() : nil

                entries.append(WeeklyMoodEntry(day: dayName, date: date, mood: randomMood))  // Pass full day name
            }
        }
        return entries
    }

    private var mockMoods: [Mood] {
        [
            Mood(
                id: "1", name: ["en": "Happy", "es": "Feliz"], description: [:],
                image:
                    "https://firebasestorage.googleapis.com/v0/b/kjomindcare.firebasestorage.app/o/moods%2Ffeliz.png?alt=media",
                color: "#FFD700", isActive: true, value: 8),
            Mood(
                id: "2", name: ["en": "Sad", "es": "Triste"], description: [:],
                image:
                    "https://firebasestorage.googleapis.com/v0/b/kjomindcare.firebasestorage.app/o/moods%2Ftriste.png?alt=media",
                color: "#4682B4", isActive: true, value: 3),
            Mood(
                id: "3", name: ["en": "Energetic", "es": "Energético"], description: [:],
                image:
                    "https://firebasestorage.googleapis.com/v0/b/kjomindcare.firebasestorage.app/o/moods%2Fenergetico.png?alt=media",
                color: "#FF4500", isActive: true, value: 9),
            Mood(
                id: "4", name: ["en": "Calm", "es": "Calmado"], description: [:],
                image:
                    "https://firebasestorage.googleapis.com/v0/b/kjomindcare.firebasestorage.app/o/moods%2Fcalmado.png?alt=media",
                color: "#98FB98", isActive: true, value: 6),
            Mood(
                id: "5", name: ["en": "Stressed", "es": "Estresado"], description: [:],
                image:
                    "https://firebasestorage.googleapis.com/v0/b/kjomindcare.firebasestorage.app/o/moods%2Festresado.png?alt=media",
                color: "#9370DB", isActive: true, value: 2),
        ]
    }
}
