//
//  CreateBlogUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class CreateBlogUseCase {
    private let repository: BlogRepository
    
    init(repository: BlogRepository) {
        self.repository = repository
    }
    
    func execute(blogPost: Blog) async throws -> String {
        return try await repository.createBlog(blogPost: blogPost)
    }
}
