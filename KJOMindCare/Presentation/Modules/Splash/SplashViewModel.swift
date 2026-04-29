
import Foundation
import Combine

class SplashViewModel: ObservableObject {
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    
    @Published var isAuthenticated: Bool = false
    
    init(checkUserSessionUseCase: CheckUserSessionUseCase) {
        self.checkUserSessionUseCase = checkUserSessionUseCase
    }
    
    func checkUserSession() {
        if let _ = checkUserSessionUseCase.execute() {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
}
