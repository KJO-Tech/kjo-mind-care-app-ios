import SwiftUI

struct CreateMoodView: View {
    @EnvironmentObject var coordinator: MoodCoordinator
    @State private var selectedMood = 3.0
    @State private var note = ""

    public var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling?")
                .font(.title)
                .fontWeight(.bold)

            Text(moodLabel(for: selectedMood))
                .font(.largeTitle)
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
                    .font(.headline)
                    .foregroundColor(.white)
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
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .gray
        }
    }
}
