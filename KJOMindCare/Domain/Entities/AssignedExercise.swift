import FirebaseFirestore
import Foundation

struct AssignedExercise: Codable, Identifiable {
    var id: String { exerciseId }  // Conforming to identifiable for convenience if needed
    var exerciseId: String
    var completed: Bool
    var completedAt: Timestamp?
    var isAdHoc: Bool?

    init(
        exerciseId: String, completed: Bool = false, completedAt: Timestamp? = nil,
        isAdHoc: Bool? = false
    ) {
        self.exerciseId = exerciseId
        self.completed = completed
        self.completedAt = completedAt
        self.isAdHoc = isAdHoc
    }
}
