//
//  AuthRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 22/11/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthRepositoryImpl: AuthRepository {
    private let authService: AuthFirebaseService
    private let firestoreService: FireStoreService
    
    init(authService: AuthFirebaseService, firestoreService: FireStoreService) {
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    func login(email: String, password: String) async throws -> User {
        let firebaseUser = try await authService.signIn(email: email, password: password)
        let user = User(uid: firebaseUser.id, fullName: firebaseUser.fullName, email: firebaseUser.email, role: "user")
        return user
    }
    
    func register(email: String, password: String, fullName: String) async throws -> User {
        let firebaseUser = try await authService.signUp(email: email, password: password)

        let user = User(
            uid: firebaseUser.uid,
            fullName: fullName,
            email: firebaseUser.email ?? "",
            role: "user",
            profileImage: nil
        )

        try await firestoreService.save(user, at: "users")

        print("Usuario registrado: \(user.fullName) (\(user.email)) con ID: \(user.id ?? "nil")")
        
        return user
    }
    
    func signOut() throws {
        try authService.signOut()
    }
    
    var currentUser: User?{
        guard let user = authService.currentUser else {
            return nil
        }
        return User(uid: user.id, fullName: user.fullName, email: user.email, role: "user")
    }
    
}
