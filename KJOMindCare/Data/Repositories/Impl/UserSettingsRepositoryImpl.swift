//
//  UserStorageRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 20/12/25.
//

import Foundation
import UIKit

class UserSettingsRepositoryImpl: UserSettingsRepository {
    private let key = "user_settings_prefs"

    func getSettings() async throws -> UserSettings {
        if let data = UserDefaults.standard.data(forKey: key),
           let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            return settings
        }
      
        return UserSettings(notificationsEnabled: false, notificationHour: Date(), darkModeEnabled: false)
    }

    func saveSettings(_ settings: UserSettings) async throws {
        let data = try JSONEncoder().encode(settings)
        UserDefaults.standard.set(data, forKey: key)
    }
}
