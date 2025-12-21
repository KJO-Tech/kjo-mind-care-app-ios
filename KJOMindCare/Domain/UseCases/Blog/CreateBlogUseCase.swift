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
    
    func execute(blogPost: Blog, mediaData: Data? = nil, mediaType: MediaType? = nil) async throws -> String {
        var updatedBlog = blogPost
        
        return try await repository.createBlog(blogPost: updatedBlog)
    }
}
