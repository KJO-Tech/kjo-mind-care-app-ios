//
//  SettingsViewModel.swift
//  KJOMindCare
//
//  Created by DAMII on 10/12/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var profile: UserProfile?
    @Published var profileImage: UIImage?
    
    
    @AppStorage("darkModeEnabled") var systemDarkMode: Bool = false
    
    private let getProfileUC = GetUserProfileUseCase()
    private let saveProfileUC = SaveUserProfileUseCase()
    private let updateNotifsUC = UpdateNotificationScheduleUseCase()
    private let notificationUC = NotificationUseCase()
    
    @MainActor
    func loadProfile() async {
        do {
            let p = try await getProfileUC.execute()
            self.profile = p
            
            self.selectedSubscriptions = Set(p.subscriptions)
            
            if let data = p.photoData {
                self.profileImage = UIImage(data: data)
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
        systemDarkMode = enabled   // ← cambia el modo oscuro real
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
    
    
    
    
    
    
    // MARK: - Subscriptions

    @Published var selectedSubscriptions: Set<SubscriptionType> = [.meditation, .movement]

    let subscriptions: [SubscriptionType] = SubscriptionType.allCases

    func toggleSubscription(_ item: SubscriptionType) {
        if selectedSubscriptions.contains(item) {
            selectedSubscriptions.remove(item)
        } else {
            selectedSubscriptions.insert(item)
        }
    }

    
    
    @MainActor
    func saveSubscriptions() async {
        guard var p = profile else { return }

      
        p.subscriptions = Array(selectedSubscriptions)

        do {
            try await saveProfileUC.execute(p)
            self.profile = p
            print("✅ Subscriptions saved:", p.subscriptions)
        } catch {
            print("❌ Error saving subscriptions:", error)
        }
    }

    


}
