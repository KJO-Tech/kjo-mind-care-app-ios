import Combine
import FirebaseCore
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject {

    // MARK: - Display Properties (from User)
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var profileImage: UIImage?
    @Published var profileImageURL: URL?
    @Published var notificationsEnabled: Bool = false
    @Published var notificationHour: Date = Date()
    @Published var darkModeEnabled: Bool = false
    @Published var isSignedOut: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies
    private let getRemoteUserUC: GetUserProfileUseCase
    private let saveRemoteUserUC: SaveUserRemoteUseCase
    private let updateLocalSettingsUC: UpdateUserSettingsUseCase
    private let signOutUseCase: SignOutUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let settingsRepo: UserSettingsRepository

    private var internalUser: User?
    private var internalSettings: UserSettings?

    init(
        signOutUseCase: SignOutUseCase,
        getRemoteUserUC: GetUserProfileUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        saveRemoteUserUC: SaveUserRemoteUseCase,
        updateLocalSettingsUC: UpdateUserSettingsUseCase,
        settingsRepo: UserSettingsRepository
    ) {
        self.signOutUseCase = signOutUseCase
        self.getRemoteUserUC = getRemoteUserUC
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.saveRemoteUserUC = saveRemoteUserUC
        self.updateLocalSettingsUC = updateLocalSettingsUC
        self.settingsRepo = settingsRepo
    }

    @MainActor
    func loadProfile() async {
      
        if let sessionUser = checkUserSessionUseCase.execute() {
            self.internalUser = sessionUser
            self.userName = sessionUser.fullName
            self.userEmail = sessionUser.email
            
            try? await fetchRemoteData(userId: sessionUser.uid)
        }

      
        if let settings = try? await settingsRepo.getSettings() {
            self.internalSettings = settings
            self.notificationsEnabled = settings.notificationsEnabled
            self.notificationHour = settings.notificationHour ?? Date()
            self.darkModeEnabled = settings.darkModeEnabled
        }
    }

    private func fetchRemoteData(userId: String) async throws {
        let remoteUser = try await getRemoteUserUC.execute(userId: userId)
        await MainActor.run {
            self.internalUser = remoteUser
            self.userName = remoteUser.fullName
            
            if let path = remoteUser.profileImage {
                let timestamp = Int(Date().timeIntervalSince1970)
                if let url = URL(string: "\(path)?t=\(timestamp)") {
                    self.profileImageURL = url
                }
            }
        }
    }

    @MainActor
    func saveProfile(name: String, email: String, image: UIImage?) async {
        guard var user = internalUser else { return }
        user.fullName = name
        
        do {
            
            let updatedUser = try await saveRemoteUserUC.execute(user: user, image: image)
            
         
            self.internalUser = updatedUser
            self.userName = updatedUser.fullName
            
         
            if let path = updatedUser.profileImage {
              
                let timestamp = Int(Date().timeIntervalSince1970)
                let freshURLString = "\(path)?t=\(timestamp)"
                
                if let url = URL(string: freshURLString) {
                    print("🔄 [ViewModel] Forzando nueva URL para romper caché: \(freshURLString)")
                    self.profileImageURL = url
                    self.profileImage = nil
                }
            }
        } catch {
            self.errorMessage = "Error al actualizar el perfil"
        }
    }

    @MainActor
    func updateNotifications(enabled: Bool, hour: Date) async {
        guard var settings = internalSettings else { return }
        settings.notificationsEnabled = enabled
        settings.notificationHour = hour
        
        try? await updateLocalSettingsUC.execute(settings)
        self.internalSettings = settings
        self.notificationsEnabled = enabled
        self.notificationHour = hour
    }

    @MainActor
    func updateDarkMode(_ enabled: Bool) async {
        guard var settings = internalSettings else { return }
        settings.darkModeEnabled = enabled
        
        try? await updateLocalSettingsUC.execute(settings)
        self.internalSettings = settings
        self.darkModeEnabled = enabled
    }

    func signOut() {
        try? signOutUseCase.execute()
        isSignedOut = true
    }
}
