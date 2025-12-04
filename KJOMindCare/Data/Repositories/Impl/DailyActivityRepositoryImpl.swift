//
//  DailyActivityRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class DailyActivityRepositoryImpl: DailyActivityRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    
    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }
    
    func getCategories() -> AnyPublisher<Resource<[ActivityCategory]>, Never> {
        let subject = PassthroughSubject<Resource<[ActivityCategory]>, Never>()
        
        subject.send(.loading)
        
        firestore.collection("activityCategories")
            .order(by: "order")
            .getDocuments { snapshot, error in
                if let error = error {
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send(.error("No documents found"))
                    subject.send(completion: .finished)
                    return
                }
                
                let categories = documents.compactMap { document -> ActivityCategory? in
                    try? document.data(as: ActivityCategory.self)
                }
                
                subject.send(.success(categories))
                subject.send(completion: .finished)
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getExercisesByCategory(categoryId: String) -> AnyPublisher<Resource<[DailyExercise]>, Never> {
        let subject = PassthroughSubject<Resource<[DailyExercise]>, Never>()
        
        subject.send(.loading)
        
        firestore.collection("dailyExercises")
            .whereField("categoryId", isEqualTo: categoryId)
            .getDocuments { snapshot, error in
                if let error = error {
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send(.error("No exercises found"))
                    subject.send(completion: .finished)
                    return
                }
                
                let exercises = documents.compactMap { document -> DailyExercise? in
                    try? document.data(as: DailyExercise.self)
                }
                
                subject.send(.success(exercises))
                subject.send(completion: .finished)
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getExerciseById(exerciseId: String) -> AnyPublisher<Resource<DailyExercise>, Never> {
        let subject = PassthroughSubject<Resource<DailyExercise>, Never>()
        
        subject.send(.loading)
        
        Task {
            do {
                let exercise: DailyExercise? = try await firestoreService.get(from: "dailyExercises", id: exerciseId)
                
                if let exercise = exercise {
                    subject.send(.success(exercise))
                } else {
                    subject.send(.error("Exercise not found"))
                }
                subject.send(completion: .finished)
            } catch {
                subject.send(.error(error.localizedDescription))
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getAllExercises() -> AnyPublisher<Resource<[DailyExercise]>, Never> {
        let subject = PassthroughSubject<Resource<[DailyExercise]>, Never>()
        
        subject.send(.loading)
        
        firestore.collection("dailyExercises")
            .getDocuments { snapshot, error in
                if let error = error {
                    subject.send(.error(error.localizedDescription))
                    subject.send(completion: .finished)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send(.error("No exercises found"))
                    subject.send(completion: .finished)
                    return
                }
                
                let exercises = documents.compactMap { document -> DailyExercise? in
                    try? document.data(as: DailyExercise.self)
                }
                
                subject.send(.success(exercises))
                subject.send(completion: .finished)
            }
        
        return subject.eraseToAnyPublisher()
    }
}
