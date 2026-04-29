import Foundation

class UpdateUserSubscriptionsUseCase {
    private let repository: ActivitySubscriptionRepository

    init(repository: ActivitySubscriptionRepository) {
        self.repository = repository
    }

    func execute(userId: String, categoryIds: [String]) async throws {
        try await repository.updateSubscriptions(userId: userId, categoryIds: categoryIds)
    }
}
