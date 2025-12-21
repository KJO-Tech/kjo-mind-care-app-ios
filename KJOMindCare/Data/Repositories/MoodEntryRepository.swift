import Combine
import Foundation

protocol MoodEntryRepository {
    func saveMoodEntry(_ entry: MoodEntry) -> AnyPublisher<Resource<MoodEntry>, Never>
    func getMoodEntries(userId: String) -> AnyPublisher<Resource<[MoodEntry]>, Never>
    func getMoodEntriesByDateRange(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<Resource<[MoodEntry]>, Never>
    func getMoodEntryById(_ id: String) -> AnyPublisher<Resource<MoodEntry>, Never>
    func deleteMoodEntry(id: String) -> AnyPublisher<Resource<Void>, Never>
}
