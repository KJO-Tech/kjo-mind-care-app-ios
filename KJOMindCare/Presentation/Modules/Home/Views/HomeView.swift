import SwiftUI

public struct HomeView: View {
    @StateObject private var coordinator = HomeCoordinator()
    @StateObject private var viewModel = DIContainer.shared.container.resolve(HomeViewModel.self)!

    let categories = ["Meditation", "Yoga", "Breathing", "Sleep Stories"]

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Welcome Header
                    VStack(alignment: .leading, spacing: 5) {
                        Text(String(format: String(localized: "Welcome %@"), viewModel.userName))
                            .font(.theme.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.theme.text)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Mood Selector Component
                    MoodSelectorView(viewModel: viewModel, coordinator: coordinator)
                        .padding(.horizontal)

                    WeeklyHistoryView()
                        .padding(.horizontal)

                    Text("Daily Activities")
                        .font(.theme.title2)
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
                                        .foregroundColor(Color.theme.primaryContent)

                                    Text(category)
                                        .font(.theme.headline)
                                        .foregroundColor(Color.theme.primaryContent)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(Color.theme.primary.opacity(0.8))
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color.theme.background.ignoresSafeArea())
            // .navigationTitle("Home") // Removing default title to use custom welcome
            .navigationBarHidden(true)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .categoryDetail(let category):
                    ActivityCategoryView(category: category)
                        .environmentObject(coordinator)
                case .exerciseDetail(let exercise):
                    ExerciseDetailView(exercise: exercise)
                        .environmentObject(coordinator)
                case .recordMood(let moodId):
                    // Passing Mood ID to RecordMoodView (Need to update RecordMoodView to handle it)
                    RecordMoodView()  // Placeholder, ideally passing moodId
                        .environmentObject(coordinator)
                        .navigationBarBackButtonHidden(true)  // Should use custom back button if custom nav
                }
            }
        }
    }

}
