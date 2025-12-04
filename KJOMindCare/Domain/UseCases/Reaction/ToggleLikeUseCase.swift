//
//  ToggleLikeUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class ToggleLikeUseCase {
    private let repository: ReactionRepository
    
    init(repository: ReactionRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String, userId: String) async throws -> Bool {
        return try await repository.toggleLike(blogId: blogId, userId: userId)
    }
}
