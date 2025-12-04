//
//  UserDailyAssignment.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct UserDailyAssignment: Codable, Identifiable {
    var id: String
    var userId: String
    var exerciseId: String
    var assignedDate: String // Format: "yyyy-MM-dd"
    var completed: Bool
    var completedAt: Timestamp?
    var createdAt: Timestamp
    
    init(
        id: String = "",
        userId: String = "",
        exerciseId: String = "",
        assignedDate: String = "",
        completed: Bool = false,
        completedAt: Timestamp? = nil,
        createdAt: Timestamp = Timestamp()
    ) {
        self.id = id
        self.userId = userId
        self.exerciseId = exerciseId
        self.assignedDate = assignedDate
        self.completed = completed
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
    
    static func getTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
