//
//  AuthFirebaseService.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Foundation
import FirebaseAuth

protocol AuthFirebaseService: AnyObject {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() throws
    var currentUser: User? { get }
}
