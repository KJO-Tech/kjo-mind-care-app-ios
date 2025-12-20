import Combine
import Foundation

class WeeklyHistoryViewModel: ObservableObject {
    @Published var weeklyHistory: [WeeklyMoodEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let getWeeklyMoodsUseCase: GetWeeklyMoodsUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        getWeeklyMoodsUseCase: GetWeeklyMoodsUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase
    ) {
        self.getWeeklyMoodsUseCase = getWeeklyMoodsUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
    }

    func loadData() {
        guard let user = checkUserSessionUseCase.execute() else {
            errorMessage = "User not logged in"
            return
        }

        isLoading = true
        getWeeklyMoodsUseCase.execute(userId: user.id, date: Date())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (resource: Resource<[WeeklyMoodEntry]>) in
                guard let self = self else { return }
                self.isLoading = false
                switch resource {
                case .loading:
                    self.isLoading = true
                case .success(let data):
                    self.weeklyHistory = data
                case .error(let message):
                    self.errorMessage = message
                }
            }
            .store(in: &cancellables)
    }
}
