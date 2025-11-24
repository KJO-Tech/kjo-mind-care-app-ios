import SwiftUI

public struct HomeView: View {
    @StateObject private var coordinator = HomeCoordinator()

    let categories = ["Meditation", "Yoga", "Breathing", "Sleep Stories"]

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Daily Activities")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15)
                    {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                coordinator.showCategoryDetail(category: category)
                            }) {
                                VStack {
                                    Image(systemName: "figure.mind.and.body")  // Placeholder
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                        .foregroundColor(.white)

                                    Text(category)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Home")
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .categoryDetail(let category):
                    ActivityCategoryView(category: category)
                        .environmentObject(coordinator)
                case .exerciseDetail(let exercise):
                    ExerciseDetailView(exercise: exercise)
                        .environmentObject(coordinator)
                }
            }
        }
    }
}
