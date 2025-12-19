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

    // MARK: - Configuration Properties (Local State)
    @Published var notificationsEnabled: Bool = false
    @Published var notificationHour: Date = Date()
    @AppStorage("darkModeEnabled") var systemDarkMode: Bool = false
    @Published var darkModeEnabled: Bool = false  // Local sync

    @Published var isSignedOut: Bool = false
    @Published var errorMessage: String? = nil

    private let getProfileUC: GetUserProfileUseCase
    private let saveProfileUC = SaveUserProfileUseCase()
    private let updateNotifsUC = UpdateNotificationScheduleUseCase()
    private let notificationUC = NotificationUseCase()
    private let signOutUseCase: SignOutUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase

    // Keep track of the full profile internally for saving updates, but don't expose it
    private var internalProfile: UserProfile?

    init(
        signOutUseCase: SignOutUseCase, getProfileUC: GetUserProfileUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase
    ) {
        self.signOutUseCase = signOutUseCase
        self.getProfileUC = getProfileUC
        self.checkUserSessionUseCase = checkUserSessionUseCase
    }

    @MainActor
    func loadProfile() async {
        guard let user = checkUserSessionUseCase.execute() else { return }

        // 1. Set Display Info from User (Fastest)
        self.userName = user.fullName
        self.userEmail = user.email

        Task {
            do {
                let fullUser = try await getProfileUC.execute(userId: user.id)
                await MainActor.run {
                    self.userName = fullUser.fullName

                    if let data = fullUser.profileImage {
                        // Check if it's a remote URL
                        if data.hasPrefix("http") || data.hasPrefix("https"),
                            let url = URL(string: data)
                        {
                            self.profileImageURL = url
                            self.profileImage = nil
                        } else {
                            // Assume local asset name
                            self.profileImage = UIImage(named: data)
                            self.profileImageURL = nil
                        }
                    }
                }
            } catch {
                print("Error fetching user profile: \(error)")
                // Keep the fallback name
            }
        }

        // 2. Load Configuration from UserProfile
        do {
            let p = try await UserProfileRepository().getProfile()
            self.internalProfile = p

            // Sync local config properties
            self.notificationsEnabled = p.notificationsEnabled
            self.notificationHour = p.notificationHour
            self.darkModeEnabled = p.darkModeEnabled

            // If User model didn't have name/image (e.g. slight sync delay), fallback or update?
            // User request: "use primarily user... for name and image" -> Done above.

        } catch {
            print("❌ Error loading profile:", error)
        }
    }

    @MainActor
    func saveProfile(name: String, email: String, image: UIImage?) async {
        guard var p = internalProfile else { return }

        // Update local display immediately
        self.userName = name
        self.userEmail = email
        self.profileImage = image

        p.name = name
        p.email = email

        if let img = image {
            p.photoData = img.jpegData(compressionQuality: 0.8)
        }

        do {
            try await saveProfileUC.execute(p)
            self.internalProfile = p
        } catch {
            print("❌ Error saving profile:", error)
        }
    }

    @MainActor
    func updateNotifications(enabled: Bool, hour: Date) async {
        guard var p = internalProfile else { return }

        // Update local state
        self.notificationsEnabled = enabled
        self.notificationHour = hour

        p.notificationsEnabled = enabled
        p.notificationHour = hour

        do {
            try await updateNotifsUC.execute(p)
            self.internalProfile = p

        } catch {
            print("❌ Error updating notif:", error)
        }
    }

    @MainActor
    func updateDarkMode(_ enabled: Bool) async {
        self.systemDarkMode = enabled
        self.darkModeEnabled = enabled

        guard var p = internalProfile else { return }
        p.darkModeEnabled = enabled

        do {
            try await saveProfileUC.execute(p)
            self.internalProfile = p
        } catch {
            print("❌ Error updating dark mode:", error)
        }
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
