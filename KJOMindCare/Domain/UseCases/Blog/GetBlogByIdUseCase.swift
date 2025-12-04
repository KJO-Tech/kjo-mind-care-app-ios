//
//  GetBlogByIdUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class GetBlogByIdUseCase {
    private let repository: BlogRepository
    
    init(repository: BlogRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String) async throws -> Blog? {
        return try await repository.getBlogById(blogId: blogId)
    }
}
