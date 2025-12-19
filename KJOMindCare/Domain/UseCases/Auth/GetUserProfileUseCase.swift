import Foundation

class GetUserProfileUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(userId: String) async throws -> User {
        return try await repository.getUserProfile(userId: userId)
    }
}
