import SwiftUI

public struct ExerciseDetailView: View {
    let exercise: String

    public var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text(exercise)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(
                "This is a placeholder for the exercise content. Imagine a video player or audio controls here."
            )
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .navigationTitle("Exercise")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
