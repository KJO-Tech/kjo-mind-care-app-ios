//
//  User.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//
import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    var uid: String
    var fullName: String
    var email: String
    var role: String
    var profileImage: String?
    var createdAt: Timestamp?

    var id: String { uid }

    init(uid: String, fullName: String, email: String, role: String, profileImage: String? = nil) {
        self.uid = uid
        self.fullName = fullName
        self.email = email
        self.role = role
        self.profileImage = profileImage
        self.createdAt = Timestamp()
    }
    
}
