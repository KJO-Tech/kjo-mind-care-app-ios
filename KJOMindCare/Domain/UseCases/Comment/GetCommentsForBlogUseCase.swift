//
//  GetCommentsForBlogUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetCommentsForBlogUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
    
    func execute(blogId: String) -> AnyPublisher<[Comment], Error> {
        return repository.getCommentsForBlog(blogId: blogId)
    }
}
