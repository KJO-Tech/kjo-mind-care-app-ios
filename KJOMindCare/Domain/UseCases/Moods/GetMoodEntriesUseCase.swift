import Combine
import FirebaseFirestore
import Foundation

final class GetMoodEntriesUseCase {
    private let repository: MoodEntryRepository

    init(repository: MoodEntryRepository) {
        self.repository = repository
    }

    func execute(userId: String) -> AnyPublisher<Resource<[MoodEntry]>, Never> {
        return repository.getMoodEntries(userId: userId)
    }

    func execute(
        userId: String, limit: Int, lastDocument: DocumentSnapshot?
    ) -> AnyPublisher<Resource<([MoodEntry], DocumentSnapshot?)>, Never> {
        return repository.getMoodEntries(
            userId: userId, limit: limit, lastDocument: lastDocument)
    }

    func execute(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<
        Resource<[MoodEntry]>, Never
    > {
        return repository.getMoodEntries(userId: userId, startDate: startDate, endDate: endDate)
    }
}
