//
//  AuthFirebaseServiceImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//
import Foundation
import FirebaseAuth

final class AutAuthFirebaseServiceImpl: AuthFirebaseService {
    
    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(id: firebaseUser.uid, name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "")
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await withUnsafeThrowingContinuation { cont in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                
                if let err = error {
                    cont.resume(throwing: err)
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1))
                    return
                }
                
                let mappedUser = User(
                    id: firebaseUser.uid,
                    name: firebaseUser.displayName ?? "",
                    email: firebaseUser.email ?? ""
                )
                
                cont.resume(returning: mappedUser)
            }
        }
    }
    
    func signUp(email: String, password: String) async throws -> User {
        try await withUnsafeThrowingContinuation { cont in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                
                if let err = error {
                    cont.resume(throwing: err)
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1))
                    return
                }
                
                let mappedUser = User(
                    id: firebaseUser.uid,
                    name: firebaseUser.displayName ?? "",
                    email: firebaseUser.email ?? ""
                )
                
                cont.resume(returning: mappedUser)
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
}
