import Combine
import FirebaseFirestore
import Foundation

protocol MoodEntryRepository {
    func addMoodEntry(_ entry: MoodEntry) -> AnyPublisher<Resource<Void>, Never>
    func getMoodEntries(userId: String) -> AnyPublisher<Resource<[MoodEntry]>, Never>
    func getMoodEntries(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<
        Resource<[MoodEntry]>, Never
    >
    func getWeeklyMoods(userId: String, date: Date) -> AnyPublisher<
        Resource<[WeeklyMoodEntry]>, Never
    >
    func getMoodStatistics(userId: String, range: TimeRange) -> AnyPublisher<
        Resource<MoodStatisticsDTO>, Never
    >
    func getMoodEntries(userId: String, limit: Int, lastDocument: DocumentSnapshot?)
        -> AnyPublisher<Resource<([MoodEntry], DocumentSnapshot?)>, Never>
}

public enum TimeRange {
    case weekly
    case monthly
    case threeMonths
    case yearly
}

public struct MoodStatisticsDTO {
    public let mostFrequentMood: Mood?
    public let moodTrend: String
    public let overallMood: Mood?
    public let distribution: [MoodDistributionItem]
    public let chartData: [MoodChartPoint]

    public init(
        mostFrequentMood: Mood?, moodTrend: String, overallMood: Mood?,
        distribution: [MoodDistributionItem], chartData: [MoodChartPoint]
    ) {
        self.mostFrequentMood = mostFrequentMood
        self.moodTrend = moodTrend
        self.overallMood = overallMood
        self.distribution = distribution
        self.chartData = chartData
    }
}
