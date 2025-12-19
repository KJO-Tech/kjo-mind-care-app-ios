//
//  BlogRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

protocol BlogRepository {
    func getBlogPosts() -> AnyPublisher<[Blog], Error>
    func getBlogById(blogId: String) async throws -> Blog?
    func createBlog(blogPost: Blog) async throws -> String
    func updateBlog(blogPost: Blog) async throws
    func updateBlogStatus(blogId: String, status: BlogStatus) async throws
    func getUserPostsCount(userId: String) -> AnyPublisher<Int, Error>
}
