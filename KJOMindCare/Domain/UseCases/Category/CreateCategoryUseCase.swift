//
//  CreateCategoryUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class CreateCategoryUseCase {
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func execute(category: Category) async throws -> String {
        return try await repository.createCategory(category: category)
    }
}
