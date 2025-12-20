import Combine
import Foundation

final class GetWeeklyMoodsUseCase {
    private let repository: MoodEntryRepository

    init(repository: MoodEntryRepository) {
        self.repository = repository
    }

    func execute(userId: String, date: Date) -> AnyPublisher<
        Resource<[WeeklyMoodEntry]>, Never
    > {
        return repository.getWeeklyMoods(userId: userId, date: date)
    }
}
