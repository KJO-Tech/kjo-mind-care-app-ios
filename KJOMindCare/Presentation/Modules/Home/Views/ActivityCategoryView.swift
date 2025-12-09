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
                        .foregroundColor(Color.theme.primary)
                    Text(exercise)
                        .font(.theme.body)
                        .foregroundStyle(Color.theme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(category)
        .scrollContentBackground(.hidden)
        .background(Color.theme.background.ignoresSafeArea())
    }
}
