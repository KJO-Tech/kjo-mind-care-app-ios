import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var currentStep = 0

    let steps = [
        WelcomeStep(
            title: "Track Your Mood", description: "Log how you feel every day to see patterns.",
            imageName: "chart.bar.fill"),
        WelcomeStep(
            title: "Read Blogs", description: "Get insights and tips from mental health experts.",
            imageName: "book.fill"),
        WelcomeStep(
            title: "Find Help", description: "Locate health centers nearby when you need them.",
            imageName: "map.fill"),
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(systemName: steps[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.blue)

                        Text(steps[index].title)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(steps[index].description)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(.gray)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

            Button(action: {
                coordinator.showLogin()
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct WelcomeStep {
    let title: String
    let description: String
    let imageName: String
}

#Preview {
    WelcomeView()
}
