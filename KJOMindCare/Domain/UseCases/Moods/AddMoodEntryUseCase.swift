import Combine
import Foundation

final class AddMoodEntryUseCase {
    private let repository: MoodEntryRepository

    init(repository: MoodEntryRepository) {
        self.repository = repository
    }

    func execute(entry: MoodEntry) -> AnyPublisher<Resource<Void>, Never> {
        return repository.addMoodEntry(entry)
    }
}
