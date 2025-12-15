//
//  UpdateCommentUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class UpdateCommentUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String, commentId: String, content: String, currentUserId: String) async throws {
        try await repository.updateComment(blogId: blogId, commentId: commentId, content: content, currentUserId: currentUserId)
    }
}
