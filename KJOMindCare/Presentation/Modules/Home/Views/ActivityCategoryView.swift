import SwiftUI

public struct ActivityCategoryView: View {
    @EnvironmentObject var coordinator: HomeCoordinator
    let category: String

    let exercises = ["Morning Calm", "Stress Relief", "Deep Sleep", "Focus Flow"]

    public var body: some View {
        List(exercises, id: \.self) { exercise in
            Button(action: {
                coordinator.showExerciseDetail(exercise: exercise)
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.blue)
                    Text(exercise)
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(category)
    }
}
