//
//  ActivitySubscriptionRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Combine
import FirebaseFirestore
import Foundation

class ActivitySubscriptionRepositoryImpl: ActivitySubscriptionRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    private let dailyActivityRepository: DailyActivityRepository

    init(firestoreService: FireStoreService, dailyActivityRepository: DailyActivityRepository) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
        self.dailyActivityRepository = dailyActivityRepository
    }

    func getUserSubscriptions(userId: String) -> AnyPublisher<Resource<ActivitySubscription>, Never>
    {
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

    func getTodayAssignedExercises(userId: String) -> AnyPublisher<
        Resource<[AssignedExerciseDetail]>, Never
    > {
        let subject = PassthroughSubject<Resource<[AssignedExerciseDetail]>, Never>()

        subject.send(.loading)

        let todayString = DailyAssignment.getTodayDateString()

        firestore.collection("dailyAssignments")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: todayString)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("DEBUG: [Repo] Error fetching today's assignment: \(error)")
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                    return
                }

                // If NO assignment found, try to auto-assign
                guard let document = snapshot?.documents.first else {
                    print("DEBUG: [Repo] No assignment found for today. Attempting auto-assign.")
                    Task {
                        do {
                            let details = try await self.assignDailyExercises(userId: userId)
                            print("DEBUG: [Repo] Auto-assigned \(details.count) exercises.")
                            subject.send(.success(details))
                        } catch {
                            print("DEBUG: [Repo] Auto-assign failed: \(error)")
                            // If assignment fails (e.g., no subscriptions), catch error but return success with empty
                            subject.send(.success([]))
                        }
                        subject.send(completion: .finished)
                    }
                    return
                }

                // If assignment found, fetch details
                do {
                    print("DEBUG: [Repo] Found existing assignment doc.")
                    let assignment = try document.data(as: DailyAssignment.self)
                    let exerciseIds = assignment.exercises.map { $0.exerciseId }
                    print("DEBUG: [Repo] Fetching details for \(exerciseIds.count) exercises.")

                    self.fetchExercisesByIds(exerciseIds: exerciseIds) { exercises in
                        print("DEBUG: [Repo] Fetched \(exercises.count) exercise details.")
                        // Map them back to detail
                        var details: [AssignedExerciseDetail] = []

                        for assigned in assignment.exercises {
                            if let exercise = exercises.first(where: {
                                ($0.id ?? "") == assigned.exerciseId
                            }) {
                                details.append(
                                    AssignedExerciseDetail(
                                        assignedExercise: assigned, exercise: exercise))
                            }
                        }

                        subject.send(.success(details))
                        subject.send(completion: .finished)
                    }
                } catch {
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                }
            }

        return subject.eraseToAnyPublisher()
    }

    func assignDailyExercises(userId: String) async throws -> [AssignedExerciseDetail] {
        let todayString = DailyAssignment.getTodayDateString()

        // 1. Get user subscriptions
        let subscriptionQuery = firestore.collection("activitySubscriptions")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)

        let subscriptionSnapshot = try await subscriptionQuery.getDocuments()

        guard let subscriptionDoc = subscriptionSnapshot.documents.first,
            let subscription = try? subscriptionDoc.data(as: ActivitySubscription.self),
            !subscription.categoryIds.isEmpty
        else {
            print("DEBUG: [Repo] No active subscriptions found for user.")
            // No subscriptions -> No exercises
            return []
        }

        print("DEBUG: [Repo] Found subscription with categories: \(subscription.categoryIds)")
        // Subscription exists, use those categories
        return try await assignExercisesFromCategories(
            userId: userId, categoryIds: subscription.categoryIds, todayString: todayString)
    }

    private func assignExercisesFromCategories(
        userId: String, categoryIds: [String], todayString: String
    ) async throws -> [AssignedExerciseDetail] {

        // 2. Fetch exercises from categories using DailyActivityRepository
        // Iterate over categories and fetch exercises for each, then aggregate
        var allExercises: [DailyExercise] = []

        // Use a task group or sequential loop. Sequential for simplicity for now as category count is low.
        // Also handling Publisher to Async conversion manually since we don't have a helper.
        for categoryId in categoryIds {
            if let exercises = try? await fetchExercisesByCategoryAsync(categoryId: categoryId) {
                allExercises.append(contentsOf: exercises)
            }
        }

        guard !allExercises.isEmpty else { return [] }

        // 3. Logic to select 3 exercises with minimal repetition
        let selectedExercises = Array(allExercises.shuffled().prefix(3))

        // 4. Create AssignedExercise list
        let assignedExercises = selectedExercises.map {
            AssignedExercise(
                exerciseId: $0.id ?? "", completed: false, completedAt: nil, isAdHoc: false)
        }

        // 5. Create DailyAssignment Document
        let newAssignment = DailyAssignment(
            userId: userId,
            date: todayString,
            exercises: assignedExercises
        )

        let collection = firestore.collection("dailyAssignments")
        try collection.addDocument(from: newAssignment)

        // 6. Return details
        return zip(assignedExercises, selectedExercises).map { assigned, exercise in
            AssignedExerciseDetail(assignedExercise: assigned, exercise: exercise)
        }
    }

    func completeExercise(userId: String, exerciseId: String) async throws {
        let todayString = DailyAssignment.getTodayDateString()

        let query = firestore.collection("dailyAssignments")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: todayString)
            .limit(to: 1)

        let snapshot = try await query.getDocuments()

        guard let document = snapshot.documents.first else {
            throw NSError(
                domain: "DailyAssignment", code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No assignment found for today"])
        }

        var assignment = try document.data(as: DailyAssignment.self)

        // Update the specific exercise in the array
        if let index = assignment.exercises.firstIndex(where: { $0.exerciseId == exerciseId }) {
            assignment.exercises[index].completed = true
            assignment.exercises[index].completedAt = Timestamp()

            // Encode the array of assignments manually
            let encodedExercises = try assignment.exercises.map {
                try Firestore.Encoder().encode($0)
            }

            // Save update
            try await firestoreService.update(
                at: "dailyAssignments",
                id: document.documentID,
                with: ["exercises": encodedExercises]
            )
        }
    }

    // MARK: - Helper Methods

    private func fetchExercisesByIds(
        exerciseIds: [String], completion: @escaping ([DailyExercise]) -> Void
    ) {
        // Keeps optimized query for bulk fetching details
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

                let exercises = documents.compactMap { document -> DailyExercise? in
                    do {
                        return try document.data(as: DailyExercise.self)
                    } catch {
                        print(
                            "DEBUG: [Repo] Error decoding exercise \(document.documentID): \(error)"
                        )
                        return nil
                    }
                }
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

    // Helper to bridge Combine Publisher to Async/Await for DailyActivityRepository
    private func fetchExercisesByCategoryAsync(categoryId: String) async throws -> [DailyExercise] {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = dailyActivityRepository.getExercisesByCategory(categoryId: categoryId)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):  // Should not happen with Never failure type in repo signature? Repo returns Never?
                        // Repo signature return type handles error in Resource enum usually
                        break
                    }
                    cancellable?.cancel()
                } receiveValue: { resource in
                    switch resource {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .error(let message):
                        continuation.resume(
                            throwing: NSError(
                                domain: "Repository", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: message]))
                    case .loading:
                        break  // Ignore loading state
                    }
                }
        }
    }
}
