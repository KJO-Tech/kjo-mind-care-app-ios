
import Foundation

class CheckUserSessionUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() -> User? {
        return repository.currentUser
    }
}
