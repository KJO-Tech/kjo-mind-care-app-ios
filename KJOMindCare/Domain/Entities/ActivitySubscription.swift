//
//  ActivitySubscription.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct ActivitySubscription: Codable, Identifiable {
    var id: String
    var userId: String
    var categoryIds: [String]
    var subscribedAt: Timestamp
    
    init(
        id: String = "",
        userId: String = "",
        categoryIds: [String] = [],
        subscribedAt: Timestamp = Timestamp()
    ) {
        self.id = id
        self.userId = userId
        self.categoryIds = categoryIds
        self.subscribedAt = subscribedAt
    }
}
