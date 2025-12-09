//
//  ReactionRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class ReactionRepositoryImpl: ReactionRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    
    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }
    
    func toggleLike(blogId: String, userId: String) async throws -> Bool {
        return try await firestore.runTransaction({ (transaction, errorPointer) -> Bool in
            let blogRef = self.firestore.collection("blogs").document(blogId)
            let likeRef = blogRef.collection("reaction").document(userId)
            
            do {
                let likeDoc = try transaction.getDocument(likeRef)
                let blogDoc = try transaction.getDocument(blogRef)
                
                guard blogDoc.exists else {
                    let error = NSError(
                        domain: "ReactionRepository",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Blog not found: \(blogId)"]
                    )
                    errorPointer?.pointee = error
                    return false
                }
                
                if likeDoc.exists {
                    // Unlike
                    transaction.deleteDocument(likeRef)
                    transaction.updateData(["reaction": FieldValue.increment(Int64(-1))], forDocument: blogRef)
                    return false
                } else {
                    // Like
                    let reactionData: [String: Any] = [
                        "userId": userId,
                        "timestamp": Timestamp()
                    ]
                    transaction.setData(reactionData, forDocument: likeRef)
                    transaction.updateData(["reaction": FieldValue.increment(Int64(1))], forDocument: blogRef)
                    return true
                }
            } catch {
                errorPointer?.pointee = error as NSError
                return false
            }
        })
    }
    
    func hasUserLikedBlog(blogId: String, userId: String) async throws -> Bool {
        let likeDoc = try await firestore
            .collection("blogs").document(blogId)
            .collection("reaction").document(userId)
            .getDocument()
        
        return likeDoc.exists
    }
    
    func getLikesForBlog(blogId: String) -> AnyPublisher<[Reaction], Error> {
        let subject = PassthroughSubject<[Reaction], Error>()
        
        let listener = firestore.collection("blogs").document(blogId)
            .collection("reaction")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let reactions = documents.compactMap { document -> Reaction? in
                    try? document.data(as: Reaction.self)
                }
                
                subject.send(reactions)
            }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
}
