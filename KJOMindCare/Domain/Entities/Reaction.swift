//
//  Reaction.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import FirebaseFirestore
import Foundation

struct Reaction: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var timestamp: Timestamp

    init(
        id: String? = nil,
        userId: String = "",
        timestamp: Timestamp = Timestamp()
    ) {
        self.id = id
        self.userId = userId
        self.timestamp = timestamp
    }
}
