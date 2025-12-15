import Combine
import Foundation

final class GetMoodEntriesByDateRangeUseCase {
    private let repository: MoodEntryRepository
    
    init(repository: MoodEntryRepository) {
        self.repository = repository
    }
    
    func execute(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<Resource<[MoodEntry]>, Never> {
        return repository.getMoodEntriesByDateRange(userId: userId, startDate: startDate, endDate: endDate)
    }
}
