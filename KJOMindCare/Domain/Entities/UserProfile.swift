//
//  UserProfile.swift
//  KJOMindCare
//
//  Created by DAMII on 10/12/25.
//

import Foundation

struct UserProfile: Codable {
    var id: String = UUID().uuidString
    var name: String
    var email: String
    var photoData: Data?      // FOTO EN LOCAL
    var notificationsEnabled: Bool
    var notificationHour: Date
    var darkModeEnabled: Bool
    var subscriptions: [SubscriptionType]
}
