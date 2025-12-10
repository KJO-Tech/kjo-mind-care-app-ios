import Combine
import Foundation

class HomeViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var moods: [Mood] = []
    @Published var selectedMoodId: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let getMoodsUseCase: GetMoodsUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let getUserProfileUseCase: GetUserProfileUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        getMoodsUseCase: GetMoodsUseCase, checkUserSessionUseCase: CheckUserSessionUseCase,
        getUserProfileUseCase: GetUserProfileUseCase
    ) {
        self.getMoodsUseCase = getMoodsUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        fetchUser()
        fetchMoods()
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
                self.isLoading = false

                switch resource {
                case .success(let moodList):
                    self.moods = moodList
                case .error(let message):
                    self.errorMessage = message
                default:
                    self.isLoading = false
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
}
