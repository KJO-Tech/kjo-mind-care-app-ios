//
//  LoginUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 29/11/25.
//

import Foundation

final class LoginUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(email: String, password: String) async throws -> User {
        return try await repository.login(email: email, password: password)
    }
}
