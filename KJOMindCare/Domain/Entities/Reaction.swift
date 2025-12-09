//
//  Reaction.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct Reaction: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var timestamp: Timestamp
    
    init(
        userId: String = "",
        timestamp: Timestamp = Timestamp()
    ) {
        self.userId = userId
        self.timestamp = timestamp
    }
}
