import Combine
import Foundation

final class GetMoodsUseCase {
    private let repository: MoodRepository

    init(repository: MoodRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<Resource<[Mood]>, Never> {
        return repository.getMoods()
    }
}
