//
//  AuthFirebaseServiceImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//
import Foundation
import FirebaseAuth
import GoogleSignIn

final class AutAuthFirebaseServiceImpl: AuthFirebaseService {

    
    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(
            uid: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? "",
            email: firebaseUser.email ?? "",
            role: "user",
            profileImage: nil
        )
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
                    uid: firebaseUser.uid,
                    fullName: firebaseUser.displayName ?? "",
                    email: firebaseUser.email ?? "",
                    role: "user"
                )
                
                cont.resume(returning: mappedUser)
            }
        }
    }
    
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
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
                
                cont.resume(returning: firebaseUser)
            }
        }
    }
    
    func signInWithGoogle() async throws -> User {
        guard let presentingVC = await UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            throw NSError(domain: "GoogleSignIn", code: -1)
        }

        let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)

        guard let idToken = googleResult.user.idToken?.tokenString else {
            throw NSError(domain: "GoogleSignIn", code: -2)
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleResult.user.accessToken.tokenString
        )

        let firebaseResult = try await Auth.auth().signIn(with: credential)
        let fUser = firebaseResult.user

        return User(
            uid: fUser.uid,
            fullName: fUser.displayName ?? "",
            email: fUser.email ?? "",
            role: "user",
            profileImage: fUser.photoURL?.absoluteString
        )
    }
    
    
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
}
