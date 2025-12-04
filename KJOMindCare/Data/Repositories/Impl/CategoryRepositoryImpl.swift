//
//  CategoryRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class CategoryRepositoryImpl: CategoryRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    
    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }
    
    func getCategories() -> AnyPublisher<[Category], Error> {
        let subject = PassthroughSubject<[Category], Error>()
        
        let listener = firestore.collection("categories")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let categories = documents.compactMap { document -> Category? in
                    try? document.data(as: Category.self)
                }
                
                subject.send(categories)
            }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
    
    func getCategoryById(categoryId: String) async throws -> Category? {
        return try await firestoreService.get(from: "categories", id: categoryId)
    }
    
    func createCategory(category: Category) async throws -> String {
        let docRef = firestore.collection("categories").document()
        var newCategory = category
        newCategory.id = docRef.documentID
        
        try docRef.setData(from: newCategory)
        return docRef.documentID
    }
    
    func deleteCategory(categoryId: String) async throws {
        try await firestoreService.update(
            at: "categories",
            id: categoryId,
            with: ["isActive": false]
        )
    }
}
