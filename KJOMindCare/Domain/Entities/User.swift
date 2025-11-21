//
//  User.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//
import Foundation

struct User: Codable, Identifiable {
    var id: String
    var name: String
    var email: String
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
