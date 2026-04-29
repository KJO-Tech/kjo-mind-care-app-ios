//
//  BlogRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Combine
import FirebaseFirestore
import Foundation

class BlogRepositoryImpl: BlogRepository {
    private let firestore: Firestore
    private let firestoreService: FireStoreService
    private let authRepository: AuthRepository

    init(firestoreService: FireStoreService, authRepository: AuthRepository) {
        self.firestore = Firestore.firestore()
        self.firestoreService = firestoreService
        self.authRepository = authRepository
    }

    func getBlogPosts() -> AnyPublisher<[Blog], any Error> {
        let userId = authRepository.currentUser?.uid ?? ""

        // Fetch ALL published blogs, no filtering
        let query = firestore.collection("blogs")
            .whereField("status", isEqualTo: BlogStatus.PUBLISHED.rawValue)
            .order(by: "createdAt", descending: true)

        return Future<[Blog], Error> { promise in
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    promise(.success([]))
                    return
                }

                Task {
                    var blogs: [Blog] = []

                    for document in documents {
                        if var blog = try? document.data(as: Blog.self) {
                            blog.id = document.documentID

                            // Get reaction count from subcollection
                            let reactionsSnapshot = try? await self.firestore.collection("blogs")
                                .document(blog.id)
                                .collection("reaction")
                                .count
                                .getAggregation(source: .server)
                            blog.likes = Int(reactionsSnapshot?.count ?? 0)

                            // Get comments count from subcollection
                            let commentsSnapshot = try? await self.firestore.collection("blogs")
                                .document(blog.id)
                                .collection("comments")
                                .count
                                .getAggregation(source: .server)
                            blog.comments = Int(commentsSnapshot?.count ?? 0)

                            // Check if current user liked this blog
                            if !userId.isEmpty {
                                let reactionDoc = try? await self.firestore.collection("blogs")
                                    .document(blog.id)
                                    .collection("reaction")
                                    .document(userId)
                                    .getDocument()
                                blog.isLiked = reactionDoc?.exists ?? false
                            } else {
                                blog.isLiked = false
                            }

                            blogs.append(blog)
                        }
                    }

                    await MainActor.run {
                        promise(.success(blogs))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getBlogById(blogId: String) async throws -> Blog? {
        // Fetch blog
        var blog: Blog? = try await firestoreService.get(from: "blogs", id: blogId)
        guard var resultBlog = blog else { return nil }

        // Ensure ID is set (prevents crash if service doesn't set it)
        if resultBlog.id.isEmpty {
            resultBlog.id = blogId
        }

        // Fetch accurate counts
        resultBlog = try await enrichBlogWithCounts(resultBlog)

        // Fetch like status if user is logged in
        if let userId = authRepository.currentUser?.uid, !userId.isEmpty {
            let reactionDoc = try await firestore.collection("blogs")
                .document(blogId)
                .collection("reaction")
                .document(userId)
                .getDocument()

            resultBlog.isLiked = reactionDoc.exists
        }

        return resultBlog
    }

    // Helper to fetch counts from subcollections
    private func enrichBlogWithCounts(_ blog: Blog) async throws -> Blog {
        guard !blog.id.isEmpty else { return blog }
        var enrichedBlog = blog

        do {
            let likesSnapshot = try await firestore.collection("blogs")
                .document(blog.id)
                .collection("reaction")
                .count
                .getAggregation(source: .server)

            let commentsSnapshot = try await firestore.collection("blogs")
                .document(blog.id)
                .collection("comments")
                .count
                .getAggregation(source: .server)

            enrichedBlog.likes = Int(truncating: likesSnapshot.count)
            enrichedBlog.comments = Int(truncating: commentsSnapshot.count)
        } catch {
            print("Error fetching counts for blog \(blog.id): \(error)")
        }

        return enrichedBlog
    }

    func createBlog(blogPost: Blog) async throws -> String {
        let docRef = firestore.collection("blogs").document()
        var newBlog = blogPost
        newBlog.id = docRef.documentID
        newBlog.createdAt = Timestamp()
        newBlog.status = .PENDING

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
            // Don't update status - keep original status
            "likes": blogPost.likes,
            "comments": blogPost.comments,
            "updatedAt": Timestamp(),
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

        return
            subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
}
