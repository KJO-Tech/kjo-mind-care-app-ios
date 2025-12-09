//
//  DeleteCategoryUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class DeleteCategoryUseCase {
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func execute(categoryId: String) async throws {
        try await repository.deleteCategory(categoryId: categoryId)
    }
}
