//
//  AddCommentUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class AddCommentUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String, comment: Comment) async throws -> String {
        return try await repository.addComment(blogId: blogId, comment: comment)
    }
}
