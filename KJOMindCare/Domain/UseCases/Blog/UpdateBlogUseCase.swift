//
//  UpdateBlogUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class UpdateBlogUseCase {
    private let repository: BlogRepository
    
    init(repository: BlogRepository) {
        self.repository = repository
    }
    
    func execute(blogPost: Blog) async throws {
        try await repository.updateBlog(blogPost: blogPost)
    }
}
