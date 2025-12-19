//
//  ActivitySubscription.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import FirebaseFirestore
import Foundation

struct ActivitySubscription: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var categoryIds: [String]
    var subscribedAt: Timestamp?

    init(
        id: String? = nil,
        userId: String = "",
        categoryIds: [String] = [],
        subscribedAt: Timestamp? = nil
    ) {
        self.id = id
        self.userId = userId
        self.categoryIds = categoryIds
        self.subscribedAt = subscribedAt
    }
}
