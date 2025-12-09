//
//  GetLikesForBlogUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetLikesForBlogUseCase {
    private let repository: ReactionRepository
    
    init(repository: ReactionRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String) -> AnyPublisher<[Reaction], Error> {
        return repository.getLikesForBlog(blogId: blogId)
    }
}
