//
//  BlogRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class BlogRepositoryImpl: BlogRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    
    init(firestoreService: FireStoreService) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
    }
    
    func getBlogPosts() -> AnyPublisher<[Blog], Error> {
        let subject = PassthroughSubject<[Blog], Error>()
        
        let listener = firestore.collection("blogs")
            .whereField("status", isEqualTo: BlogStatus.PUBLISHED.rawValue)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let blogs = documents.compactMap { document -> Blog? in
                    try? document.data(as: Blog.self)
                }
                
                subject.send(blogs)
            }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
    
    func getBlogById(blogId: String) async throws -> Blog? {
        return try await firestoreService.get(from: "blogs", id: blogId)
    }
    
    func createBlog(blogPost: Blog) async throws -> String {
        let docRef = firestore.collection("blogs").document()
        var newBlog = blogPost
        newBlog.id = docRef.documentID
        newBlog.createdAt = Timestamp()
        newBlog.status = .PUBLISHED
        
        try docRef.setData(from: newBlog)
        return docRef.documentID
    }
    
    func updateBlog(blogPost: Blog) async throws {
        let updates: [String: Any] = [
            "title": blogPost.title,
            "content": blogPost.content,
            "mediaUrl": blogPost.mediaUrl as Any,
            "mediaType": blogPost.mediaType?.rawValue as Any,
            "categoryId": blogPost.categoryId as Any,
            "status": blogPost.status.rawValue,
            "likes": blogPost.likes,
            "comments": blogPost.comments,
            "updatedAt": Timestamp()
        ]
        
        try await firestoreService.update(at: "blogs", id: blogPost.id, with: updates)
    }
    
    func updateBlogStatus(blogId: String, status: BlogStatus) async throws {
        try await firestoreService.update(
            at: "blogs",
            id: blogId,
            with: ["status": status.rawValue]
        )
    }
    
    func getUserPostsCount(userId: String) -> AnyPublisher<Int, Error> {
        let subject = PassthroughSubject<Int, Error>()
        
        guard !userId.isEmpty else {
            subject.send(0)
            subject.send(completion: .finished)
            return subject.eraseToAnyPublisher()
        }
        
        let listener = firestore.collection("blogs")
            .whereField("author.uid", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                let count = snapshot?.documents.count ?? 0
                subject.send(count)
            }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
}
