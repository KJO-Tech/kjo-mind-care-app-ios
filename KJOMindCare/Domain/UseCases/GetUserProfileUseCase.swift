//
//  GetUserProfileUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

class GetUserProfileUseCase {
    private let repo = UserProfileRepository()
    
    func execute() async throws -> UserProfile {
        try await repo.getProfile()
    }
}
