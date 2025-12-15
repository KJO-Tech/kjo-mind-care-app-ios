import Combine
import Foundation
import SwiftUI

class SubscriptionViewModel: ObservableObject {
    @Published var categories: [ActivityCategory] = []
    @Published var selectedCategoryIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Dependencies
    private let getActivityCategoriesUseCase: GetActivityCategoriesUseCase
    private let getUserSubscriptionsUseCase: GetUserSubscriptionsUseCase
    private let updateUserSubscriptionsUseCase: UpdateUserSubscriptionsUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let coordinator: AppCoordinator

    // State
    let isEditMode: Bool
    private var subscribers = Set<AnyCancellable>()

    init(
        getActivityCategoriesUseCase: GetActivityCategoriesUseCase,
        getUserSubscriptionsUseCase: GetUserSubscriptionsUseCase,
        updateUserSubscriptionsUseCase: UpdateUserSubscriptionsUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        coordinator: AppCoordinator,
        isEditMode: Bool = false
    ) {
        self.getActivityCategoriesUseCase = getActivityCategoriesUseCase
        self.getUserSubscriptionsUseCase = getUserSubscriptionsUseCase
        self.updateUserSubscriptionsUseCase = updateUserSubscriptionsUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.coordinator = coordinator
        self.isEditMode = isEditMode

        loadData()
    }

    func loadData() {
        guard let userId = checkUserSessionUseCase.execute()?.id else {
            errorMessage = "User not logged in"  // Should localize
            return
        }

        isLoading = true
        errorMessage = nil

        // 1. Fetch Categories
        getActivityCategoriesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to load categories"
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] resource in
                guard let self = self else { return }
                switch resource {
                case .success(let categories):
                    self.categories = categories
                    self.fetchUserSubscriptions(userId: userId)
                case .error(let err):
                    self.isLoading = false
                    self.errorMessage = err
                case .loading:
                    break
                }
            }
            .store(in: &subscribers)
    }

    private func fetchUserSubscriptions(userId: String) {
        getUserSubscriptionsUseCase.execute(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handled in value
            } receiveValue: { [weak self] resource in
                guard let self = self else { return }
                switch resource {
                case .success(let sub):
                    self.selectedCategoryIds = Set(sub.categoryIds)
                    self.isLoading = false
                case .error(let err):
                    self.errorMessage = err
                    self.isLoading = false
                case .loading:
                    break
                }
            }
            .store(in: &subscribers)
    }

    func toggleCategory(id: String) {
        if selectedCategoryIds.contains(id) {
            selectedCategoryIds.remove(id)
        } else {
            selectedCategoryIds.insert(id)
        }
    }

    // Callback for dismissal (to handle popping from different coordinators)
    var onDismiss: (() -> Void)?

    func save() {
        guard let userId = checkUserSessionUseCase.execute()?.id else { return }

        Task { @MainActor in
            isLoading = true
            do {
                try await updateUserSubscriptionsUseCase.execute(
                    userId: userId, categoryIds: Array(selectedCategoryIds))
                isLoading = false
                if isEditMode {
                    goBack()
                } else {
                    skip()
                }
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func skip() {
        coordinator.showMain()
    }

    func goBack() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            // Fallback for standalone usage or if not set (though strictly shouldn't happen in profile)
            coordinator.pop()
        }
    }
}
