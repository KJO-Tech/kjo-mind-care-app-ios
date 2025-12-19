//
//  SettingsViewModel.swift
//  KJOMindCare
//
//  Created by DAMII on 10/12/25.
//

import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {

    @Published var profile: UserProfile?
    @Published var user: User?
    @Published var profileImage: UIImage?
    @Published var isSignedOut: Bool = false
    @Published var errorMessage: String? = nil

    @AppStorage("darkModeEnabled") var systemDarkMode: Bool = false

    private let getProfileUseCase: GetUserProfileUseCase
    private let saveProfileUC = SaveUserProfileUseCase()
    private let updateNotifsUC = UpdateNotificationScheduleUseCase()
    private let notificationUC = NotificationUseCase()
    private let signOutUseCase: SignOutUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase

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
        do {
            let p = try await getProfileUC.execute(userId: user.id)
            // self.profile = p
            self.user = user

            if let data = user.profileImage {
                self.profileImage = UIImage(named: data)
            }

        } catch {
            print("❌ Error loading profile:", error)
        }
    }

    @MainActor
    func saveProfile(name: String, email: String, image: UIImage?) async {
        guard var p = profile else { return }
        p.name = name
        p.email = email

        if let img = image {
            p.photoData = img.jpegData(compressionQuality: 0.8)
        }

        do {
            try await saveProfileUC.execute(p)
            self.profile = p
            self.profileImage = image
        } catch {
            print("❌ Error saving profile:", error)
        }
    }

    @MainActor
    func updateNotifications(enabled: Bool, hour: Date) async {
        guard var p = profile else { return }

        p.notificationsEnabled = enabled
        p.notificationHour = hour

        do {
            try await updateNotifsUC.execute(p)
            self.profile = p

        } catch {
            print("❌ Error updating notif:", error)
        }
    }

    @MainActor
    func updateDarkMode(_ enabled: Bool) async {
        systemDarkMode = enabled  // ← cambia el modo oscuro real
        guard var p = profile else { return }
        p.darkModeEnabled = enabled

        do {
            try await saveProfileUC.execute(p)
            self.profile = p
        } catch {
            print("❌ Error updating dark mode:", error)
        }
    }

    // Accesos rápidos
    var name: String { profile?.name ?? "" }
    var email: String { profile?.email ?? "" }

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
