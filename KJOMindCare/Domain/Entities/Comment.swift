import Foundation

public struct Comment: Identifiable, Codable, Equatable {
    public let id: UUID
    public let blogId: UUID
    public let authorId: String
    public let authorName: String
    public var content: String
    public let createdAt: Date
    public var updatedAt: Date
    public let parentCommentId: UUID? 
    public var replies: [Comment]
    
    public var isReply: Bool {
        parentCommentId != nil
    }
    

    public init(
        id: UUID = UUID(),
        blogId: UUID,
        authorId: String,
        authorName: String,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        parentCommentId: UUID? = nil,
        replies: [Comment] = []
    ) {
        self.id = id
        self.blogId = blogId
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.parentCommentId = parentCommentId
        self.replies = replies
    }
}

extension Comment {
    static let mockList: [Comment] = [
        Comment(
            blogId: UUID(),
            authorId: "user1",
            authorName: "kevin Briceño Quezada",
            content: "La salud mental es realmente importante",
            createdAt: Date().addingTimeInterval(-4*30*86400),
            replies: [
                Comment(
                    blogId: UUID(),
                    authorId: "user2",
                    authorName: "Otar",
                    content: "Lamentablemente en la actualidad no se le da la debida importancia",
                    createdAt: Date().addingTimeInterval(-4*30*86400),
                    parentCommentId: UUID()
                )
            ]
        ),
        Comment(
            blogId: UUID(),
            authorId: "user3",
            authorName: "Allan Sagastegui",
            content: "Tienes mucha razón, pero no se da la importancia necesaria.",
            createdAt: Date().addingTimeInterval(-4*30*86400)
        ),
        Comment(
            blogId: UUID(),
            authorId: "user4",
            authorName: "Kevin",
            content: "Buen recurso",
            createdAt: Date().addingTimeInterval(-11*86400)
        )
    ]
}
