//
//  CompleteExerciseUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class CompleteExerciseUseCase {
    private let repository: ActivitySubscriptionRepository
    
    init(repository: ActivitySubscriptionRepository) {
        self.repository = repository
    }
    
    func execute(userId: String, exerciseId: String) async throws {
        try await repository.completeExercise(userId: userId, exerciseId: exerciseId)
    }
}
