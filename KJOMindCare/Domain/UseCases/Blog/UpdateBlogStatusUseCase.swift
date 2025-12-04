//
//  UpdateBlogStatusUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class UpdateBlogStatusUseCase {
    private let repository: BlogRepository
    
    init(repository: BlogRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String, status: BlogStatus) async throws {
        try await repository.updateBlogStatus(blogId: blogId, status: status)
    }
}
