//
//  RegisterUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 22/11/25.
//

import Foundation

final class RegisterUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(email: String, password: String, fullName: String) async throws -> User {
        return try await repository.register(email: email, password: password, fullName: fullName)
    }
}
