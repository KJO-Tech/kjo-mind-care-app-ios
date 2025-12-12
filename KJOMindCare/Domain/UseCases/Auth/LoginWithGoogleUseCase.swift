//
//  LoginGoogleUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

final class LoginWithGoogleUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> User {
        return try await repository.loginWithGoogle()
    }
}
