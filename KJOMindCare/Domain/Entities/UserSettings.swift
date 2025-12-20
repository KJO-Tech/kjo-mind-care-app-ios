//
//  UserProfile.swift
//  KJOMindCare
//
//  Created by DAMII on 10/12/25.
//

import Foundation

struct UserSettings: Codable {
    var notificationsEnabled: Bool
    var notificationHour: Date
    var darkModeEnabled: Bool
}
