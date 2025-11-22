//
//  AuthRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 22/11/25.
//
import Foundation
import FirebaseAuth

class AuthRepositoryImpl: AuthRepository {
    private let authService: AuthFirebaseService
    private let firestoreService: FireStoreService
    
    init(authService: AuthFirebaseService, firestoreService: FireStoreService) {
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    func login(email: String, password: String) async throws -> User {
        let firebaseUser = try await authService.signIn(email: email, password: password)
        let user = User(id: firebaseUser.id, name: firebaseUser.name, email: firebaseUser.email)
        return user
    }
    
    func register(email: String, password: String) async throws -> User {
        let firebaseUser = try await authService.signUp(email: email, password: password)
        let user = User(id: firebaseUser.id, name: firebaseUser.name, email: firebaseUser.email)
        try await firestoreService.save(user, at: "users")
        return user
    }
    
    func signOut() throws {
        try authService.signOut()
    }
    
    var currentUser: User?{
        guard let user = authService.currentUser else {
            return nil
        }
        return User(id: user.id, name: user.name, email: user.email)
    }
    

}
