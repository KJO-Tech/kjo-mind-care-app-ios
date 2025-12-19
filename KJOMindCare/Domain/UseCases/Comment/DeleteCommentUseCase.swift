//
//  DeleteCommentUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class DeleteCommentUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String, commentId: String, currentUserId: String) async throws {
        try await repository.deleteComment(blogId: blogId, commentId: commentId, currentUserId: currentUserId)
    }
}
