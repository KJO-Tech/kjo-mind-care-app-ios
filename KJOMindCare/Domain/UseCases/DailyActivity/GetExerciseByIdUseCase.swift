//
//  GetExerciseByIdUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetExerciseByIdUseCase {
    private let repository: DailyActivityRepository
    
    init(repository: DailyActivityRepository) {
        self.repository = repository
    }
    
    func execute(exerciseId: String) -> AnyPublisher<Resource<DailyExercise>, Never> {
        return repository.getExerciseById(exerciseId: exerciseId)
    }
}
