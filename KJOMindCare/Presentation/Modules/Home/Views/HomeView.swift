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

                    // Weekly History Component
                    WeeklyHistoryView()
                        .padding(.horizontal)

                    // Daily Activities Section
                    DailyActivitiesView(
                        assignments: viewModel.dailyAssignments,
                        categories: viewModel.activityCategories,
                        isLoading: viewModel.isLoading,
                        onSeeAll: {
                            coordinator.showCategoryList()
                        },
                        onExerciseSelected: { exerciseId in
                            coordinator.showExerciseDetail(exerciseId: exerciseId)
                        }
                    )
                    .padding(.horizontal)

                    Spacer(minLength: 80)
                }
                .padding(.vertical, 20)
            }
            .background(Color.theme.background)
            // .navigationTitle("Home") // Removing default title to use custom welcome
            .navigationBarHidden(true)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .categoryList:
                    if let vm = DIContainer.shared.container.resolve(CategoryListViewModel.self) {
                        CategoryListView(
                            viewModel: vm,
                            onCategorySelected: { categoryId in
                                coordinator.showCategoryDetail(categoryId: categoryId)
                            },
                            onBack: {
                                coordinator.path.removeLast()
                            }
                        )
                    } else {
                        Text("Error loading categories")
                    }
                case .categoryDetail(let categoryId):
                    if let vm = DIContainer.shared.container.resolve(
                        CategoryDetailViewModel.self, argument: categoryId)
                    {
                        CategoryDetailView(
                            viewModel: vm,
                            onBack: { coordinator.path.removeLast() },
                            onExerciseSelected: { exerciseId in
                                coordinator.showExerciseDetail(exerciseId: exerciseId)
                            }
                        )
                        .environmentObject(coordinator)
                    } else {
                        Text("Error loading category")
                    }
                case .exerciseDetail(let exerciseId):
                    if let vm = DIContainer.shared.container.resolve(
                        ExerciseDetailViewModel.self, argument: exerciseId)
                    {
                        ExerciseDetailView(
                            viewModel: vm,
                            onBack: { coordinator.path.removeLast() }
                        )
                        .environmentObject(coordinator)
                    } else {
                        Text("Error loading exercise")
                    }
                case .recordMood(let moodId):
                    // Passing Mood ID to RecordMoodView
                    RecordMoodView(selectedMoodId: moodId)
                        .environmentObject(coordinator)
                }
            }
        }
        .onAppear {
            // Refresh data when view appears (e.g. returning from detail)
            viewModel.fetchDailyActivities()
            // Also refresh categories if needed, but less critical
        }
    }

}
