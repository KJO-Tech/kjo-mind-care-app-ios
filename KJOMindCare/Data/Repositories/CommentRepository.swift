//
//  CommentRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

protocol CommentRepository {
    func getCommentsForBlog(blogId: String) -> AnyPublisher<[Comment], Error>
    func addComment(blogId: String, comment: Comment) async throws -> String
    func updateComment(blogId: String, commentId: String, content: String, currentUserId: String) async throws
    func deleteComment(blogId: String, commentId: String, currentUserId: String) async throws
    func addReply(blogId: String, parentCommentId: String, reply: Comment) async throws -> String
}
