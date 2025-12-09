import SwiftUI

struct CreateMoodView: View {
    @EnvironmentObject var coordinator: MoodCoordinator
    @State private var selectedMood = 3.0
    @State private var note = ""

    public var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.theme.title)
                .fontWeight(.bold)

            Text("Select a mood")
                .font(.theme.largeTitle)
                .padding()

            Slider(value: $selectedMood, in: 1...5, step: 1)
                .padding()
                .accentColor(moodColor(for: selectedMood))

            TextField("Add a note...", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                // Save logic here
                coordinator.pop()
            }) {
                Text("Save Mood")
                    .font(.theme.headline)
                    .foregroundColor(Color.theme.primaryContent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(moodColor(for: selectedMood))
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("Log Mood")
    }

    func moodLabel(for value: Double) -> String {
        switch Int(value) {
        case 1: return "😢 Terrible"
        case 2: return "😟 Bad"
        case 3: return "😐 Okay"
        case 4: return "🙂 Good"
        case 5: return "😄 Amazing"
        default: return ""
        }
    }

    func moodColor(for value: Double) -> Color {
        switch Int(value) {
        case 1: return Color.theme.error
        case 2: return Color.theme.warning
        case 3: return .yellow
        case 4: return Color.theme.success
        case 5: return Color.theme.primary
        default: return Color.theme.textSecondary
        }
    }
}
