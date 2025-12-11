import Combine
import Foundation

@MainActor
class CategoryDetailViewModel: ObservableObject {
    @Published var category: ActivityCategory?
    @Published var exercises: [DailyExercise] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let categoryId: String
    // We assume we might need a use case to get category by ID if we only pass ID.
    // Or we filter from all categories.
    // Let's assume we have `GetActivityCategoriesUseCase` and we filter, or `GetCategoryById` if strict.
    // Since `GetActivityCategoriesUseCase` is what we have used, I'll use that and filter for now to avoid creating new UC if possible.
    // Also `GetExercisesByCategoryUseCase` is needed.

    private let getActivityCategoriesUseCase: GetActivityCategoriesUseCase
    private let getExercisesByCategoryUseCase: GetExercisesByCategoryUseCase

    private var cancellables = Set<AnyCancellable>()

    nonisolated init(
        categoryId: String,
        getActivityCategoriesUseCase: GetActivityCategoriesUseCase,
        getExercisesByCategoryUseCase: GetExercisesByCategoryUseCase
    ) {
        self.categoryId = categoryId
        self.getActivityCategoriesUseCase = getActivityCategoriesUseCase
        self.getExercisesByCategoryUseCase = getExercisesByCategoryUseCase
    }

    func onViewAppear() {
        fetchCategory()
        fetchExercises()
    }

    private func fetchCategory() {
        // Ideally we'd have GetCategoryById, but fetching all is cached usually so cheap enough for now
        getActivityCategoriesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resource in
                guard let self = self else { return }
                if case .success(let categories) = resource {
                    self.category = categories.first(where: { $0.id == self.categoryId })
                }
            }
            .store(in: &cancellables)
    }

    private func fetchExercises() {
        isLoading = true
        getExercisesByCategoryUseCase.execute(categoryId: categoryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resource in
                guard let self = self else { return }
                self.isLoading = false
                switch resource {
                case .success(let list):
                    self.exercises = list
                case .error(let message):
                    self.errorMessage = message
                case .loading:
                    self.isLoading = true
                }
            }
            .store(in: &cancellables)
    }
}
