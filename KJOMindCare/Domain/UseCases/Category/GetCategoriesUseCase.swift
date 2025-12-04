//
//  GetCategoriesUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetCategoriesUseCase {
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[Category], Error> {
        return repository.getCategories()
    }
}
