import SwiftUI

public enum CommentMode {
    case create
    case edit(Comment)
    case reply(Comment)
}

@MainActor
public class BlogDetailViewModel: ObservableObject {
    @Published var blog: Blog
    @Published var comments: [Comment] = []
    @Published var isLiked: Bool = false
    @Published var likeCount: Int = 0
    
    // Comment input
    @Published var showCommentInput: Bool = false
    @Published var commentMode: CommentMode = .create
    @Published var commentText: String = ""
    
    // Delete dialog
    @Published var showDeleteDialog: Bool = false
    @Published var itemToDelete: DeleteItem? = nil
    
    public enum DeleteItem: Equatable {
        case blog
        case comment(Comment)
    }
    
    let currentUserId: String = "current-user-id" // Reemplazar con ID real del usuario
    
    public init(blog: Blog) {
        self.blog = blog
        self.isLiked = blog.isLiked
        self.likeCount = blog.likes
        self.comments = Comment.mockList
    }
    
    // MARK: - Blog Actions
    
    func toggleLike() {
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        
       
    }
    
    func sharePost() {
       
    }
    
    func editBlog() {
      
    }
    
    func deleteBlog() {
        itemToDelete = .blog
        showDeleteDialog = true
    }
    
    func confirmDeleteBlog() {
        showDeleteDialog = false
    }
    
    // MARK: - Comment Actions
    
    func addComment() {
        commentMode = .create
        commentText = ""
        showCommentInput = true
    }
    
    func replyToComment(_ comment: Comment) {
        commentMode = .reply(comment)
        commentText = ""
        showCommentInput = true
    }
    
    func editComment(_ comment: Comment) {
        commentMode = .edit(comment)
        commentText = comment.content
        showCommentInput = true
    }
    
    func deleteComment(_ comment: Comment) {
        itemToDelete = .comment(comment)
        showDeleteDialog = true
    }
    
    func saveComment() {
        guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        switch commentMode {
        case .create:
            let newComment = Comment(
                blogId: blog.id,
                authorId: currentUserId,
                authorName: "Current User",
                content: commentText
            )
            comments.append(newComment)
            
        case .edit(let comment):
            if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                comments[index].content = commentText
                comments[index].updatedAt = Date()
            }
            
        case .reply(let parentComment):
            let reply = Comment(
                blogId: blog.id,
                authorId: currentUserId,
                authorName: "Current User",
                content: commentText,
                parentCommentId: parentComment.id
            )
            
            if let index = comments.firstIndex(where: { $0.id == parentComment.id }) {
                comments[index].replies.append(reply)
            }
        }
        
        showCommentInput = false
        commentText = ""
    }
    
    func cancelComment() {
        showCommentInput = false
        commentText = ""
    }
    
    func confirmDeleteComment() {
        guard case .comment(let comment) = itemToDelete else { return }
        

        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            comments.remove(at: index)
        } else {
            for (index, var parentComment) in comments.enumerated() {
                if let replyIndex = parentComment.replies.firstIndex(where: { $0.id == comment.id }) {
                    comments[index].replies.remove(at: replyIndex)
                    break
                }
            }
        }
        
        showDeleteDialog = false
        itemToDelete = nil
    }
    
    func isMyComment(_ comment: Comment) -> Bool {
        return comment.authorId == currentUserId
    }
    
    var isMyBlog: Bool {
        return blog.isMyBlog(currentUserId: currentUserId)
    }
}
