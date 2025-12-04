//
//  DailyActivityRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

protocol DailyActivityRepository {
    func getCategories() -> AnyPublisher<Resource<[ActivityCategory]>, Never>
    func getExercisesByCategory(categoryId: String) -> AnyPublisher<Resource<[DailyExercise]>, Never>
    func getExerciseById(exerciseId: String) -> AnyPublisher<Resource<DailyExercise>, Never>
    func getAllExercises() -> AnyPublisher<Resource<[DailyExercise]>, Never>
}
