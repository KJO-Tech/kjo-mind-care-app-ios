//
//  GetTodayAssignedExercisesUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetTodayAssignedExercisesUseCase {
    private let repository: ActivitySubscriptionRepository
    
    init(repository: ActivitySubscriptionRepository) {
        self.repository = repository
    }
    
    func execute(userId: String) -> AnyPublisher<Resource<[DailyExercise]>, Never> {
        return repository.getTodayAssignedExercises(userId: userId)
    }
}
