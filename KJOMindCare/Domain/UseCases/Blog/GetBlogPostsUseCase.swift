//
//  GetBlogPostsUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetBlogPostsUseCase {
    private let repository: BlogRepository
    
    init(repository: BlogRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[Blog], Error> {
        return repository.getBlogPosts()
    }
}
