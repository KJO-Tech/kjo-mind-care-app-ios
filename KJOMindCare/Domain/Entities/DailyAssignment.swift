import FirebaseFirestore
import Foundation

struct DailyAssignment: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var date: String  // YYYY-MM-DD
    var exercises: [AssignedExercise]

    init(id: String? = nil, userId: String, date: String, exercises: [AssignedExercise]) {
        self.id = id
        self.userId = userId
        self.date = date
        self.exercises = exercises
    }

    static func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
