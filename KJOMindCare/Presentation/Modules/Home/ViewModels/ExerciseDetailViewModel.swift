import Combine
import Foundation

@MainActor
class ExerciseDetailViewModel: ObservableObject {
    @Published var exercise: DailyExercise?
    @Published var isCompleted: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let exerciseId: String
    private let getExerciseByIdUseCase: GetExerciseByIdUseCase
    private let completeExerciseUseCase: CompleteExerciseUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    // We might need to check if it's already completed today.
    // The previous implementation utilized HomeViewModel's list.
    // Here we might need a way to check status.
    // For now, completion will be optimistic or handled via the result of "complete".
    // Ideally, we fetch the assignment status too, or pass it.
    // User said "solo reciben el id como string".
    // So we fetch exercise. Completion status might require fetching today's assignments or checking a specific record.
    // For simplicity and to follow the request: fetch exercise.
    // Status check might need an extra UseCase or we fetch today's assignments here too?
    // Let's stick to simple Exercise fetch first.

    // UPDATE: To know if it's completed, we typically need the assignment record.
    // I'll add `getTodayAssignedExercisesUseCase` here to check status on load?
    // Or maybe duplicate that logic?
    // Let's start with fetching the exercise details.

    private let getTodayAssignedExercisesUseCase: GetTodayAssignedExercisesUseCase

    private var cancellables = Set<AnyCancellable>()

    nonisolated init(
        exerciseId: String,
        getExerciseByIdUseCase: GetExerciseByIdUseCase,
        completeExerciseUseCase: CompleteExerciseUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        getTodayAssignedExercisesUseCase: GetTodayAssignedExercisesUseCase
    ) {
        self.exerciseId = exerciseId
        self.getExerciseByIdUseCase = getExerciseByIdUseCase
        self.completeExerciseUseCase = completeExerciseUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.getTodayAssignedExercisesUseCase = getTodayAssignedExercisesUseCase
    }

    func onViewAppear() {
        fetchExercise()
        checkCompletionStatus()
    }

    func fetchExercise() {
        isLoading = true
        getExerciseByIdUseCase.execute(exerciseId: exerciseId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resource in
                guard let self = self else { return }
                self.isLoading = false
                switch resource {
                case .success(let exercise):
                    self.exercise = exercise
                case .error(let message):
                    self.errorMessage = message
                case .loading:
                    self.isLoading = true
                }
            }
            .store(in: &cancellables)
    }

    func checkCompletionStatus() {
        guard let user = checkUserSessionUseCase.execute() else { return }

        getTodayAssignedExercisesUseCase.execute(userId: user.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resource in
                guard let self = self else { return }
                if case .success(let assignments) = resource {
                    if let assignment = assignments.first(where: {
                        $0.exerciseId == self.exerciseId
                    }) {
                        self.isCompleted = assignment.completed
                    }
                }
            }
            .store(in: &cancellables)
    }

    func completeExercise() {
        guard let user = checkUserSessionUseCase.execute() else { return }

        // Optimistic
        isCompleted = true

        Task {
            do {
                try await completeExerciseUseCase.execute(userId: user.id, exerciseId: exerciseId)
            } catch {
                print("Error completing: \(error)")
                await MainActor.run {
                    self.isCompleted = false  // Revert
                    self.errorMessage = "Failed to complete exercise"
                }
            }
        }
    }
}
