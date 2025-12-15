import Combine
import Foundation

final class SaveMoodEntryUseCase {
    private let repository: MoodEntryRepository
    
    init(repository: MoodEntryRepository) {
        self.repository = repository
    }
    
    func execute(userId: String, mood: String, note: String = "") -> AnyPublisher<Resource<MoodEntry>, Never> {
        let entry = MoodEntry(
            userId: userId,
            mood: mood,
            note: note
        )
        return repository.saveMoodEntry(entry)
    }
}
