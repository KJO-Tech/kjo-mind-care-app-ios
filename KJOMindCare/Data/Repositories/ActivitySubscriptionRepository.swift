//
//  ActivitySubscriptionRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

protocol ActivitySubscriptionRepository {
    func getUserSubscriptions(userId: String) -> AnyPublisher<Resource<ActivitySubscription>, Never>
    func subscribeToCategory(userId: String, categoryId: String) async throws
    func unsubscribeFromCategory(userId: String, categoryId: String) async throws
    func getTodayAssignedExercises(userId: String) -> AnyPublisher<Resource<[DailyExercise]>, Never>
    func assignDailyExercises(userId: String) async throws -> [DailyExercise]
    func completeExercise(userId: String, exerciseId: String) async throws
}
