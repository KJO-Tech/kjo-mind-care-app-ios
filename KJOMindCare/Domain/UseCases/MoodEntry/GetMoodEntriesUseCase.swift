import Combine
import Foundation

final class GetMoodEntriesUseCase {
    private let repository: MoodEntryRepository
    
    init(repository: MoodEntryRepository) {
        self.repository = repository
    }
    
    func execute(userId: String) -> AnyPublisher<Resource<[MoodEntry]>, Never> {
        return repository.getMoodEntries(userId: userId)
    }
}
