import Combine
import Foundation

class CategoryListViewModel: ObservableObject {
    @Published var categories: [ActivityCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let getActivityCategoriesUseCase: GetActivityCategoriesUseCase
    private var cancellables = Set<AnyCancellable>()

    init(getActivityCategoriesUseCase: GetActivityCategoriesUseCase) {
        self.getActivityCategoriesUseCase = getActivityCategoriesUseCase
    }

    func onViewAppear() {
        fetchCategories()
    }

    func fetchCategories() {
        isLoading = true
        errorMessage = nil
        print("DEBUG: [CategoryListViewModel] fetching categories...")

        getActivityCategoriesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resource in
                guard let self = self else { return }
                self.isLoading = false

                switch resource {
                case .success(let categories):
                    print("DEBUG: [CategoryListViewModel] fetched \(categories.count) categories.")
                    self.categories = categories
                case .error(let message):
                    print("DEBUG: [CategoryListViewModel] Error: \(message)")
                    self.errorMessage = message
                case .loading:
                    self.isLoading = true
                }
            }
            .store(in: &cancellables)
    }
}
