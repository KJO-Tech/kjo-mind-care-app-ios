//
//  GetUserPostsCountUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetUserPostsCountUseCase {
    private let repository: BlogRepository
    
    init(repository: BlogRepository) {
        self.repository = repository
    }
    
    func execute(userId: String) -> AnyPublisher<Int, Error> {
        return repository.getUserPostsCount(userId: userId)
    }
}
