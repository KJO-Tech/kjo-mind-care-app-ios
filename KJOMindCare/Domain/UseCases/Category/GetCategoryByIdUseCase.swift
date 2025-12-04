//
//  GetCategoryByIdUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class GetCategoryByIdUseCase {
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func execute(categoryId: String) async throws -> Category? {
        return try await repository.getCategoryById(categoryId: categoryId)
    }
}
