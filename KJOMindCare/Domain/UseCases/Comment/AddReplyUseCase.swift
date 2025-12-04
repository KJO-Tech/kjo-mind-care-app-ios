//
//  AddReplyUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class AddReplyUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String, parentCommentId: String, reply: Comment) async throws -> String {
        return try await repository.addReply(blogId: blogId, parentCommentId: parentCommentId, reply: reply)
    }
}
