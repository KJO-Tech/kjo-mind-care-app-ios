//
//  SignOutUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

import Foundation

final class SignOutUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute() throws {
        try repository.signOut()
    }
}
