import SwiftUI

public struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var coordinator: HomeCoordinator

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome Header
                VStack(alignment: .leading, spacing: 5) {
                    Text(String(format: String(localized: "Welcome %@"), viewModel.userName))
                        .font(.theme.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.theme.primary)
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
        .navigationBarHidden(true)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            // Only load on first appear
            if viewModel.dailyAssignments.isEmpty {
                await viewModel.fetchDailyActivities()
            }
        }
    }
}
