import Combine
import Foundation

class ProfileViewModel: ObservableObject {
    private let signOutUseCase: SignOutUseCase

    @Published var errorMessage: String? = nil
    @Published var isSignedOut: Bool = false

    init(signOutUseCase: SignOutUseCase) {
        self.signOutUseCase = signOutUseCase
    }

    func signOut() {
        do {
            try signOutUseCase.execute()
            isSignedOut = true
        } catch {
            print("Error signing out: \(error)")
            errorMessage = "Failed to sign out. Please try again."
        }
    }
}
