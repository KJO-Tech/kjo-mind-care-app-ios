//
//  ActivitySubscriptionRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class ActivitySubscriptionRepositoryImpl: ActivitySubscriptionRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    
    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }
    
    func getUserSubscriptions(userId: String) -> AnyPublisher<Resource<ActivitySubscription>, Never> {
        let subject = PassthroughSubject<Resource<ActivitySubscription>, Never>()
        
        subject.send(.loading)
        
        firestore.collection("activitySubscriptions")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    // No subscription found, return empty
                    let emptySubscription = ActivitySubscription(userId: userId, categoryIds: [])
                    subject.send(.success(emptySubscription))
                    subject.send(completion: .finished)
                    return
                }
                
                do {
                    let subscription = try document.data(as: ActivitySubscription.self)
                    subject.send(.success(subscription))
                    subject.send(completion: .finished)
                } catch {
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                }
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func subscribeToCategory(userId: String, categoryId: String) async throws {
        let query = firestore.collection("activitySubscriptions")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        if let document = snapshot.documents.first {
            // Update existing subscription
            var subscription = try document.data(as: ActivitySubscription.self)
            if !subscription.categoryIds.contains(categoryId) {
                subscription.categoryIds.append(categoryId)
                try await firestoreService.update(
                    at: "activitySubscriptions",
                    id: document.documentID,
                    with: ["categoryIds": subscription.categoryIds]
                )
            }
        } else {
            // Create new subscription
            let newSubscription = ActivitySubscription(
                userId: userId,
                categoryIds: [categoryId],
                subscribedAt: Timestamp()
            )
            let docRef = firestore.collection("activitySubscriptions").document()
            try docRef.setData(from: newSubscription)
        }
    }
    
    func unsubscribeFromCategory(userId: String, categoryId: String) async throws {
        let query = firestore.collection("activitySubscriptions")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        guard let document = snapshot.documents.first else {
            return
        }
        
        var subscription = try document.data(as: ActivitySubscription.self)
        subscription.categoryIds.removeAll { $0 == categoryId }
        
        try await firestoreService.update(
            at: "activitySubscriptions",
            id: document.documentID,
            with: ["categoryIds": subscription.categoryIds]
        )
    }
    
    func getTodayAssignedExercises(userId: String) -> AnyPublisher<Resource<[DailyExercise]>, Never> {
        let subject = PassthroughSubject<Resource<[DailyExercise]>, Never>()
        
        subject.send(.loading)
        
        let todayString = UserDailyAssignment.getTodayDateString()
        
        firestore.collection("dailyAssignments")
            .whereField("userId", isEqualTo: userId)
            .whereField("assignedDate", isEqualTo: todayString)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    subject.send(.success([]))
                    subject.send(completion: .finished)
                    return
                }
                
                let assignments = documents.compactMap { try? $0.data(as: UserDailyAssignment.self) }
                let exerciseIds = assignments.map { $0.exerciseId }
                
                // Fetch exercises
                self.fetchExercisesByIds(exerciseIds: exerciseIds) { exercises in
                    subject.send(.success(exercises))
                    subject.send(completion: .finished)
                }
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func assignDailyExercises(userId: String) async throws -> [DailyExercise] {
        let todayString = UserDailyAssignment.getTodayDateString()
        
        // Check if already assigned for today
        let existingQuery = firestore.collection("dailyAssignments")
            .whereField("userId", isEqualTo: userId)
            .whereField("assignedDate", isEqualTo: todayString)
        
        let existingSnapshot = try await existingQuery.getDocuments()
        
        if !existingSnapshot.documents.isEmpty {
            // Already assigned, fetch and return existing exercises
            let assignments = existingSnapshot.documents.compactMap { try? $0.data(as: UserDailyAssignment.self) }
            let exerciseIds = assignments.map { $0.exerciseId }
            return try await fetchExercisesByIdsAsync(exerciseIds: exerciseIds)
        }
        
        // Get user subscriptions
        let subscriptionQuery = firestore.collection("activitySubscriptions")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
        
        let subscriptionSnapshot = try await subscriptionQuery.getDocuments()
        
        guard let subscriptionDoc = subscriptionSnapshot.documents.first else {
            throw NSError(domain: "ActivitySubscription", code: 404, userInfo: [NSLocalizedDescriptionKey: "No subscriptions found"])
        }
        
        let subscription = try subscriptionDoc.data(as: ActivitySubscription.self)
        
        guard !subscription.categoryIds.isEmpty else {
            throw NSError(domain: "ActivitySubscription", code: 400, userInfo: [NSLocalizedDescriptionKey: "No category subscriptions"])
        }
        
        // Fetch all exercises from subscribed categories
        let exercisesQuery = firestore.collection("dailyExercises")
            .whereField("categoryId", in: subscription.categoryIds)
        
        let exercisesSnapshot = try await exercisesQuery.getDocuments()
        let allExercises = exercisesSnapshot.documents.compactMap { try? $0.data(as: DailyExercise.self) }
        
        guard !allExercises.isEmpty else {
            throw NSError(domain: "DailyExercise", code: 404, userInfo: [NSLocalizedDescriptionKey: "No exercises found for subscribed categories"])
        }
        
        // Randomly select 5 exercises
        let selectedExercises = Array(allExercises.shuffled().prefix(5))
        
        // Create assignments
        let batch = firestore.batch()
        
        for exercise in selectedExercises {
            let assignmentRef = firestore.collection("dailyAssignments").document()
            let assignment = UserDailyAssignment(
                id: assignmentRef.documentID,
                userId: userId,
                exerciseId: exercise.id,
                assignedDate: todayString,
                completed: false,
                completedAt: nil,
                createdAt: Timestamp()
            )
            
            try batch.setData(from: assignment, forDocument: assignmentRef)
        }
        
        try await batch.commit()
        
        return selectedExercises
    }
    
    func completeExercise(userId: String, exerciseId: String) async throws {
        let todayString = UserDailyAssignment.getTodayDateString()
        
        let query = firestore.collection("dailyAssignments")
            .whereField("userId", isEqualTo: userId)
            .whereField("exerciseId", isEqualTo: exerciseId)
            .whereField("assignedDate", isEqualTo: todayString)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw NSError(domain: "UserDailyAssignment", code: 404, userInfo: [NSLocalizedDescriptionKey: "Assignment not found"])
        }
        
        try await firestoreService.update(
            at: "userDailyAssignments",
            id: document.documentID,
            with: [
                "completed": true,
                "completedAt": Timestamp()
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private func fetchExercisesByIds(exerciseIds: [String], completion: @escaping ([DailyExercise]) -> Void) {
        guard !exerciseIds.isEmpty else {
            completion([])
            return
        }
        
        firestore.collection("dailyExercises")
            .whereField(FieldPath.documentID(), in: exerciseIds)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let exercises = documents.compactMap { try? $0.data(as: DailyExercise.self) }
                completion(exercises)
            }
    }
    
    private func fetchExercisesByIdsAsync(exerciseIds: [String]) async throws -> [DailyExercise] {
        guard !exerciseIds.isEmpty else {
            return []
        }
        
        let snapshot = try await firestore.collection("dailyExercises")
            .whereField(FieldPath.documentID(), in: exerciseIds)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: DailyExercise.self) }
    }
}
