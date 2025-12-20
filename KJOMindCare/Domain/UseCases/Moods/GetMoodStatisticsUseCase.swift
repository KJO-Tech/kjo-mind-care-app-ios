import Combine
import Foundation

final class GetMoodStatisticsUseCase {
    private let repository: MoodEntryRepository

    init(repository: MoodEntryRepository) {
        self.repository = repository
    }

    func execute(userId: String, range: TimeRange) -> AnyPublisher<
        Resource<MoodStatisticsDTO>, Never
    > {
        return repository.getMoodStatistics(userId: userId, range: range)
    }
}
