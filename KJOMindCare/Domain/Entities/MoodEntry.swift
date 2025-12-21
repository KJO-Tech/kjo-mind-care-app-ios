import Foundation

public struct MoodEntry: Identifiable, Codable {
    public let id: String
    public let moodId: String?
    public let note: String
    public let userId: String
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString, moodId: String?, note: String, userId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.moodId = moodId
        self.note = note
        self.userId = userId
        self.createdAt = createdAt
    }
}
