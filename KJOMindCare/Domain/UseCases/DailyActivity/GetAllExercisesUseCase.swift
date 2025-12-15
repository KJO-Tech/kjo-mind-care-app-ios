//
//  GetAllExercisesUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetAllExercisesUseCase {
    private let repository: DailyActivityRepository
    
    init(repository: DailyActivityRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Resource<[DailyExercise]>, Never> {
        return repository.getAllExercises()
    }
}
