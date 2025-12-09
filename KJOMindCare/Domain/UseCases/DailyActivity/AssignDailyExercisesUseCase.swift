//
//  AssignDailyExercisesUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class AssignDailyExercisesUseCase {
    private let repository: ActivitySubscriptionRepository
    
    init(repository: ActivitySubscriptionRepository) {
        self.repository = repository
    }
    
    func execute(userId: String) async throws -> [DailyExercise] {
        return try await repository.assignDailyExercises(userId: userId)
    }
}
