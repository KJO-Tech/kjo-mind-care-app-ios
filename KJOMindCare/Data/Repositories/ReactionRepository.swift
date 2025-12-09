//
//  ReactionRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

protocol ReactionRepository {
    func toggleLike(blogId: String, userId: String) async throws -> Bool
    func hasUserLikedBlog(blogId: String, userId: String) async throws -> Bool
    func getLikesForBlog(blogId: String) -> AnyPublisher<[Reaction], Error>
}
