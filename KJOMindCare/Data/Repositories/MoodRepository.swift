import Combine
import Foundation

protocol MoodRepository {
    func getMoods() -> AnyPublisher<Resource<[Mood]>, Never>
}
