import SwiftUI

struct HomeCoordinatorView: View {
    @StateObject private var coordinator = HomeCoordinator()
    let homeViewModel: HomeViewModel

    // ViewModels cache to prevent recreation
    @StateObject private var categoryListVM: CategoryListViewModel = DIContainer.shared.container
        .resolve(CategoryListViewModel.self)!
    @State private var categoryDetailVMs: [String: CategoryDetailViewModel] = [:]
    @State private var exerciseDetailVMs: [String: ExerciseDetailViewModel] = [:]

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(viewModel: homeViewModel)
                .environmentObject(coordinator)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .categoryList:
                        CategoryListView(
                            viewModel: categoryListVM,
                            onCategorySelected: { categoryId in
                                coordinator.showCategoryDetail(categoryId: categoryId)
                            }
                        )

                    case .categoryDetail(let categoryId):
                        CategoryDetailView(
                            viewModel: getCategoryDetailViewModel(for: categoryId),
                            onExerciseSelected: { exerciseId in
                                coordinator.showExerciseDetail(exerciseId: exerciseId)
                            }
                        )

                    case .exerciseDetail(let exerciseId):
                        ExerciseDetailView(
                            viewModel: getExerciseDetailViewModel(for: exerciseId),
                            onComplete: {
                                coordinator.pop()
                                Task {
                                    await homeViewModel.fetchDailyActivities()
                                }
                            }
                        )

                    case .recordMood(let moodId):
                        RecordMoodView(
                            selectedMoodId: moodId,
                            onComplete: {
                                coordinator.pop()
                                Task {
                                    await homeViewModel.fetchDailyActivities()
                                }
                            }
                        )
                    }
                }
        }
        .environmentObject(coordinator)
        .tint(Color.theme.text)
    }

    // Helper methods to get or create cached ViewModels
    private func getCategoryDetailViewModel(for categoryId: String) -> CategoryDetailViewModel {
        if let existing = categoryDetailVMs[categoryId] {
            return existing
        }

        let newVM = DIContainer.shared.container.resolve(
            CategoryDetailViewModel.self, argument: categoryId)!
        categoryDetailVMs[categoryId] = newVM
        return newVM
    }

    private func getExerciseDetailViewModel(for exerciseId: String) -> ExerciseDetailViewModel {
        if let existing = exerciseDetailVMs[exerciseId] {
            return existing
        }

        let newVM = DIContainer.shared.container.resolve(
            ExerciseDetailViewModel.self, argument: exerciseId)!
        exerciseDetailVMs[exerciseId] = newVM
        return newVM
    }
}
