import Charts
import SwiftUI

public struct MoodListView: View {
    @StateObject private var coordinator = MoodCoordinator()

    // Placeholder data
    let moodHistory = [
        (day: "Mon", value: 3),
        (day: "Tue", value: 4),
        (day: "Wed", value: 2),
        (day: "Thu", value: 5),
        (day: "Fri", value: 4),
    ]

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack {
                Text("Mood History")
                    .font(.theme.title2)
                    .fontWeight(.bold)
                    .padding()

                // Simple Chart using SwiftUI Charts (iOS 16+)
                Chart {
                    ForEach(moodHistory, id: \.day) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Mood", item.value)
                        )
                        .foregroundStyle(Color.theme.primary.gradient)
                    }
                }
                .frame(height: 200)
                .padding()

                List {
                    ForEach(moodHistory, id: \.day) { item in
                        HStack {
                            Text(item.day)
                            Spacer()
                            Text("Mood Level: \(item.value)")
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)

                Button(action: {
                    coordinator.showCreateMood()
                }) {
                    Text("Log Mood")
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.primaryContent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.primary)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Moods")
            .background(Color.theme.background.ignoresSafeArea())
            .navigationDestination(for: MoodRoute.self) { route in
                switch route {
                case .createMood:
                    CreateMoodView()
                        .environmentObject(coordinator)
                }
            }
        }
    }
}
