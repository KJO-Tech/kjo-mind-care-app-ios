//
//  UnsubscribeFromCategoryUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class UnsubscribeFromCategoryUseCase {
    private let repository: ActivitySubscriptionRepository
    
    init(repository: ActivitySubscriptionRepository) {
        self.repository = repository
    }
    
    func execute(userId: String, categoryId: String) async throws {
        try await repository.unsubscribeFromCategory(userId: userId, categoryId: categoryId)
    }
}
