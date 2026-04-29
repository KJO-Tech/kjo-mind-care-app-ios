import FirebaseFirestore
import Foundation

struct AssignedExerciseDetail: Identifiable, Codable {
    var id: String { exerciseId }
    var exerciseId: String
    var completed: Bool
    var completedAt: Timestamp?
    var isAdHoc: Bool?
    var exercise: DailyExercise

    init(assignedExercise: AssignedExercise, exercise: DailyExercise) {
        self.exerciseId = assignedExercise.exerciseId
        self.completed = assignedExercise.completed
        self.completedAt = assignedExercise.completedAt
        self.isAdHoc = assignedExercise.isAdHoc
        self.exercise = exercise
    }

    // Helper to convert get back base struct
    func toAssignedExercise() -> AssignedExercise {
        return AssignedExercise(
            exerciseId: exerciseId, completed: completed, completedAt: completedAt, isAdHoc: isAdHoc
        )
    }
}
