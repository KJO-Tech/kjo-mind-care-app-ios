//
//  UserProfileRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

import UIKit

protocol UserSettingsRepository {
    func getSettings() async throws -> UserSettings
    func saveSettings(_ settings: UserSettings) async throws
}
