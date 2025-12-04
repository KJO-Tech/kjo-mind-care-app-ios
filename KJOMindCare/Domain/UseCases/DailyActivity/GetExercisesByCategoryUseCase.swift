//
//  GetExercisesByCategoryUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

final class GetExercisesByCategoryUseCase {
    private let repository: DailyActivityRepository
    
    init(repository: DailyActivityRepository) {
        self.repository = repository
    }
    
    func execute(categoryId: String) -> AnyPublisher<Resource<[DailyExercise]>, Never> {
        return repository.getExercisesByCategory(categoryId: categoryId)
    }
}
