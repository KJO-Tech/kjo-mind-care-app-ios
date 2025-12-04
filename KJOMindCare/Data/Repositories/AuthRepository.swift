//
//  AuthRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 22/11/25.
//
import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func register(email: String, password: String, fullName: String) async throws -> User
    func signOut() throws
    var currentUser: User? { get }
}

