import Combine
import FirebaseCore
import Foundation

class HomeViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var moods: [Mood] = []
    @Published var selectedMoodId: String? = nil
    @Published var dailyAssignments: [AssignedExerciseDetail] = []
    @Published var activityCategories: [ActivityCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let getMoodsUseCase: GetMoodsUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let getTodayAssignedExercisesUseCase: GetTodayAssignedExercisesUseCase
    private let getActivityCategoriesUseCase: GetActivityCategoriesUseCase

    private var cancellables = Set<AnyCancellable>()

    init(
        getMoodsUseCase: GetMoodsUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        getUserProfileUseCase: GetUserProfileUseCase,
        getTodayAssignedExercisesUseCase: GetTodayAssignedExercisesUseCase,
        getActivityCategoriesUseCase: GetActivityCategoriesUseCase
    ) {
        self.getMoodsUseCase = getMoodsUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        self.getTodayAssignedExercisesUseCase = getTodayAssignedExercisesUseCase
        self.getActivityCategoriesUseCase = getActivityCategoriesUseCase

        fetchUser()
        fetchData()
    }

    func fetchData() {
        fetchMoods()
        fetchDailyActivities()
        fetchActivityCategories()
    }

    func fetchUser() {
        guard let user = checkUserSessionUseCase.execute() else {
            self.userName = "Guest"
            return
        }

        // Fallback initially
        self.userName = user.fullName.isEmpty ? user.email : user.fullName

        // Fetch full profile asynchronously
        Task {
            do {
                let fullUser = try await getUserProfileUseCase.execute(userId: user.id)
                await MainActor.run {
                    self.userName = fullUser.fullName
                }
            } catch {
                print("Error fetching user profile: \(error)")
                // Keep the fallback name
            }
        }
    }

    func fetchMoods() {
        isLoading = true
        errorMessage = nil

        getMoodsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<[Mood]>) in
                guard let self = self else { return }
                // We don't set isLoading false here yet because other requests might be running
                // Ideally use Combine.Zip or similar, but for now simple parallelism

                switch resource {
                case .success(let moodList):
                    self.moods = moodList
                case .error(let message):
                    self.errorMessage = message
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func fetchDailyActivities() {
        guard let user = checkUserSessionUseCase.execute() else { return }

        // Don't overwrite isLoading if it's already true from fetchMoods, but ensure we handle it
        if !isLoading { isLoading = true }

        print("DEBUG: [HomeViewModel] fetching daily activities for user \(user.id)...")
        getTodayAssignedExercisesUseCase.execute(userId: user.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<[AssignedExerciseDetail]>) in
                guard let self = self else { return }

                switch resource {
                case .success(let assignments):
                    print("DEBUG: [HomeViewModel] fetched \(assignments.count) assignments.")
                    self.dailyAssignments = assignments
                    self.performLoadingCheck()
                case .error(let message):
                    print("DEBUG: [HomeViewModel] Error fetching assignments: \(message)")
                    self.errorMessage = message
                    self.performLoadingCheck()
                case .loading:
                    self.isLoading = true
                }
            }
            .store(in: &cancellables)
    }

    private func performLoadingCheck() {
        // Simple check: if assignments are loaded (or error), we stop loading.
        // Ideally we track multiple requests, but for now this suffices as moods are fast/less critical for layout
        self.isLoading = false
    }

    func fetchActivityCategories() {
        print("DEBUG: [HomeViewModel] fetching categories...")
        getActivityCategoriesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<[ActivityCategory]>) in
                guard let self = self else { return }

                switch resource {
                case .success(let categories):
                    print("DEBUG: [HomeViewModel] fetched \(categories.count) categories.")
                    self.activityCategories = categories
                case .error(let message):
                    print("DEBUG: [HomeViewModel] Error fetching categories: \(message)")
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func selectMood(id: String) {
        if selectedMoodId == id {
            selectedMoodId = nil  // Deselect if already selected
        } else {
            selectedMoodId = id
        }
    }

    func refresh() async {
        guard let user = checkUserSessionUseCase.execute() else {
            return
        }

        await MainActor.run {
            self.isLoading = true
        }

        // Use Combine publisher with continuation
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            getTodayAssignedExercisesUseCase.execute(userId: user.id)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (resource: Resource<[AssignedExerciseDetail]>) in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }

                    switch resource {
                    case .success(let assignments):
                        self.dailyAssignments = assignments
                    case .error(let message):
                        self.errorMessage = message
                    case .loading:
                        break
                    }
                    self.isLoading = false
                    continuation.resume()
                }
                .store(in: &self.cancellables)
        }
    }
}
