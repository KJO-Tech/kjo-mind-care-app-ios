import Foundation

public struct WeeklyMoodEntry: Identifiable {
    public let id: String
    public let day: String
    public let date: Date
    public let mood: Mood?

    public init(id: String = UUID().uuidString, day: String, date: Date, mood: Mood?) {
        self.id = id
        self.day = day
        self.date = date
        self.mood = mood
    }
}
