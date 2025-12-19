//
//  HasUserLikedBlogUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class HasUserLikedBlogUseCase {
    private let repository: ReactionRepository
    
    init(repository: ReactionRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String, userId: String) async throws -> Bool {
        return try await repository.hasUserLikedBlog(blogId: blogId, userId: userId)
    }
}
