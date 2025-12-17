//
//  UserProfileRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

import Foundation
import UIKit

class UserProfileRepository {
    
    private let key = "local_user_profile"
    
    func getProfile() async throws -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: key),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        
        let defaultProfile = UserProfile(
            name: "Nuevo Usuario",
            email: "email@correo.com",
            photoData: nil,
            notificationsEnabled: false,
            notificationHour: Date(),
            darkModeEnabled: false,
            subscriptions: []
        )
        
        try saveProfile(defaultProfile)
        return defaultProfile
    }
    
    func saveProfile(_ profile: UserProfile) throws {
        let data = try JSONEncoder().encode(profile)
        UserDefaults.standard.set(data, forKey: key)
    }
}


