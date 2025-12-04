//
//  CommentRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class CommentRepositoryImpl: CommentRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    
    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }
    
    func getCommentsForBlog(blogId: String) -> AnyPublisher<[Comment], Error> {
        let subject = PassthroughSubject<[Comment], Error>()
        
        let listener = firestore.collection("blogs").document(blogId)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let comments = documents.compactMap { document -> Comment? in
                    try? document.data(as: Comment.self)
                }
                
                subject.send(comments)
            }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
    
    func addComment(blogId: String, comment: Comment) async throws -> String {
        let docRef = firestore.collection("blogs").document(blogId).collection("comments").document()
        var newComment = comment
        newComment.id = docRef.documentID
        newComment.createdAt = Timestamp()
        
        try docRef.setData(from: newComment)
        
        // Increment comment count on blog
        try await firestoreService.update(
            at: "blogs",
            id: blogId,
            with: ["comments": FieldValue.increment(Int64(1))]
        )
        
        return docRef.documentID
    }
    
    func updateComment(blogId: String, commentId: String, content: String, currentUserId: String) async throws {
        // First, verify ownership
        let commentDoc = try await firestore.collection("blogs").document(blogId)
            .collection("comments").document(commentId)
            .getDocument()
        
        guard commentDoc.exists else {
            throw NSError(domain: "CommentRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Comment not found"])
        }
        
        let comment = try commentDoc.data(as: Comment.self)
        
        guard comment.isMine(currentUserId: currentUserId) else {
            throw NSError(domain: "CommentRepository", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only edit your own comments"])
        }
        
        // Update comment
        try await firestore.collection("blogs").document(blogId)
            .collection("comments").document(commentId)
            .updateData(["content": content])
    }
    
    func deleteComment(blogId: String, commentId: String, currentUserId: String) async throws {
        // First, verify ownership
        let commentDoc = try await firestore.collection("blogs").document(blogId)
            .collection("comments").document(commentId)
            .getDocument()
        
        guard commentDoc.exists else {
            throw NSError(domain: "CommentRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Comment not found"])
        }
        
        let comment = try commentDoc.data(as: Comment.self)
        
        guard comment.isMine(currentUserId: currentUserId) else {
            throw NSError(domain: "CommentRepository", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only delete your own comments"])
        }
        
        // Delete comment
        try await firestore.collection("blogs").document(blogId)
            .collection("comments").document(commentId)
            .delete()
        
        // Decrement comment count on blog
        try await firestoreService.update(
            at: "blogs",
            id: blogId,
            with: ["comments": FieldValue.increment(Int64(-1))]
        )
    }
    
    func addReply(blogId: String, parentCommentId: String, reply: Comment) async throws -> String {
        let docRef = firestore.collection("blogs").document(blogId).collection("comments").document()
        var newReply = reply
        newReply.id = docRef.documentID
        newReply.parentCommentId = parentCommentId
        newReply.createdAt = Timestamp()
        
        try docRef.setData(from: newReply)
        
        // Increment comment count on blog
        try await firestoreService.update(
            at: "blogs",
            id: blogId,
            with: ["comments": FieldValue.increment(Int64(1))]
        )
        
        return docRef.documentID
    }
}
