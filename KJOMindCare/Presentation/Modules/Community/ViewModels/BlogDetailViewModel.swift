import Combine
import SwiftUI

@MainActor
class BlogDetailViewModel: ObservableObject {
    @Published var blog: Blog?
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Comment Input
    @Published var showCommentInput: Bool = false
    @Published var commentText: String = ""
    @Published var commentMode: CommentMode = .create

    // UI Support
    var authorName: String { blog?.author.fullName ?? "" }
    var likeCount: Int { blog?.likes ?? 0 }
    @Published var categoryName: String = ""
    var isLiked: Bool { blog?.isLiked ?? false }
    var isMyBlog: Bool {
        guard let user = checkUserSessionUseCase.execute(), let blog = blog else { return false }
        return blog.author.uid == user.uid
    }

    var totalCommentsCount: Int {
        comments.reduce(0) { $0 + 1 + $1.replies.count }
    }

    var currentUserId: String {
        checkUserSessionUseCase.execute()?.uid ?? ""
    }

    enum DeleteItem { case blog, comment }
    @Published var showDeleteDialog = false
    @Published var itemToDelete: DeleteItem?

    let blogId: String
    private let getBlogByIdUseCase: GetBlogByIdUseCase
    private let getCommentsForBlogUseCase: GetCommentsForBlogUseCase
    private let addCommentUseCase: AddCommentUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let getCategoryByIdUseCase: GetCategoryByIdUseCase
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let toggleLikeUseCase: ToggleLikeUseCase

    nonisolated init(
        blogId: String,
        getBlogByIdUseCase: GetBlogByIdUseCase,
        getCommentsForBlogUseCase: GetCommentsForBlogUseCase,
        addCommentUseCase: AddCommentUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        getCategoryByIdUseCase: GetCategoryByIdUseCase,
        getUserProfileUseCase: GetUserProfileUseCase,
        toggleLikeUseCase: ToggleLikeUseCase
    ) {
        self.blogId = blogId
        self.getBlogByIdUseCase = getBlogByIdUseCase
        self.getCommentsForBlogUseCase = getCommentsForBlogUseCase
        self.addCommentUseCase = addCommentUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.getCategoryByIdUseCase = getCategoryByIdUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
    }

    private var cancellables = Set<AnyCancellable>()

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        await loadBlog()
        await loadCategory()
        loadComments()
    }

    func loadCategory() async {
        guard let categoryId = blog?.categoryId else { return }
        do {
            if let category = try await getCategoryByIdUseCase.execute(categoryId: categoryId) {
                // Get localized name manually or use helper if available.
                // Assuming Category has getLocalizedName or similar logic. Entity check needed.
                // The entity has a method getLocalizedName(languageCode:).
                let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
                self.categoryName = category.getLocalizedName(languageCode: languageCode)
            }
        } catch {
            print("Error loading category: \(error)")
        }
    }

    func loadBlog() async {
        print("BlogDetailViewModel: Loading blog with ID: \(blogId)")
        do {
            if let fetchedBlog = try await getBlogByIdUseCase.execute(blogId: blogId) {
                print("BlogDetailViewModel: Blog found: \(fetchedBlog.title)")
                self.blog = fetchedBlog
            } else {
                print("BlogDetailViewModel: Blog not found for ID: \(blogId)")
                errorMessage = "Blog not found"
            }
        } catch {
            print("Error loading blog: \(error)")
            errorMessage = "Error loading blog"
        }
    }

    func loadComments() {
        print("BlogDetailViewModel: Starting comments listener")
        // Check if we already have a subscription if desirable, but here we'll just replace it.
        // Or store in a specific cancellable to allow cancellation.

        getCommentsForBlogUseCase.execute(blogId: blogId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error loading comments: \(error)")
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] extractedComments in
                self?.processComments(extractedComments)
            }
            .store(in: &cancellables)  // Need to define cancellables set if not present
    }

    // Sub-function to keep logic clean
    private func processComments(_ extractedComments: [Comment]) {
        // Threading logic: Separate parents and replies
        var commentMap = [String: Comment]()
        var rootComments = [Comment]()

        // First pass: Index all comments
        for comment in extractedComments {
            if let id = comment.id {
                commentMap[id] = comment
            }
        }

        // Second pass: Associate replies
        for comment in extractedComments {
            if let parentId = comment.parentCommentId, !parentId.isEmpty {
                if var parent = commentMap[parentId] {
                    parent.replies.append(comment)
                    commentMap[parentId] = parent
                }
            } else {
                rootComments.append(comment)
            }
        }

        // Third pass: Reconstruct root list using map values?
        // Actually, we need to sort replies.

        var finalRoots = [Comment]()
        let repliesByParent = Dictionary(
            grouping: extractedComments.filter {
                $0.parentCommentId != nil && !$0.parentCommentId!.isEmpty
            }
        ) { $0.parentCommentId! }

        let roots = extractedComments.filter {
            $0.parentCommentId == nil || $0.parentCommentId!.isEmpty
        }

        for var root in roots {
            if let id = root.id, let replies = repliesByParent[id] {
                root.replies = replies.sorted(by: {
                    $0.createdAt.dateValue() < $1.createdAt.dateValue()
                })
            }
            finalRoots.append(root)
        }

        self.comments = finalRoots.sorted(by: {
            $0.createdAt.dateValue() < $1.createdAt.dateValue()
        })
    }

    func addComment() {
        commentMode = .create
        commentText = ""
        showCommentInput = true
    }

    func saveComment() async {
        guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let user = checkUserSessionUseCase.execute() else { return }

        do {
            // Fetch full profile to get name and image (crucial fix)
            let author: User
            let profile = try await getUserProfileUseCase.execute(userId: user.uid)
            author = profile ?? user

            switch commentMode {
            case .create:
                let comment = Comment(
                    author: author,
                    content: commentText
                )
                try await addCommentUseCase.execute(blogId: blogId, comment: comment)

            case .reply(let parent):
                var comment = Comment(
                    author: author,
                    content: commentText
                )
                comment.parentCommentId = parent.id
                try await addCommentUseCase.execute(blogId: blogId, comment: comment)

            case .edit(let comment):
                print("Edit not implemented yet")
                break
            }

            // Optimistic update for comment count
            if case .create = commentMode { blog?.comments += 1 }
            if case .reply = commentMode { blog?.comments += 1 }

            commentText = ""
            showCommentInput = false
            // loadComments() is live, so no need to manually call unless we want to force re-sub (not needed for listener)
        } catch {
            print("Error saving comment: \(error)")
            errorMessage = "Error saving comment"
        }
    }

    func cancelComment() {
        showCommentInput = false
        commentText = ""
    }

    // MARK: - Actions
    func toggleLike() {
        guard let blog = blog, let user = checkUserSessionUseCase.execute() else { return }

        // Optimistic update
        let isCurrentlyLiked = isLiked
        self.blog?.isLiked = !isCurrentlyLiked
        self.blog?.likes += (isCurrentlyLiked ? -1 : 1)

        Task {
            do {
                _ = try await toggleLikeUseCase.execute(blogId: blog.id, userId: user.uid)
                // Real-time listener usually updates 'isLiked' automatically but 'likes' count requires re-fetch.
                // Since we did optimistic update, we might be fine, but to be sure we can reload Blog metadata silently.
                // However, reloadBlog() triggers a spinner or updates 'blog' which might overwrite our optimistic state if backend is slow?
                // Actually, backend update is fast. But let's stick to optimistic.
            } catch {
                // Revert on error
                self.blog?.isLiked = isCurrentlyLiked
                self.blog?.likes += (isCurrentlyLiked ? 1 : -1)
                print("Error toggling like: \(error)")
            }
        }
    }

    func editBlog() {
        guard let blog = blog else { return }
        // Note: This requires coordinator to be injected or accessed via environment
        // For now, this is a placeholder that would need coordinator access
        print("Edit blog: \(blog.id)")
    }

    func deleteBlog() {
        itemToDelete = .blog
        showDeleteDialog = true
    }

    func confirmDeleteBlog() {
        // Call DeleteBlogUseCase
    }

    func isMyComment(_ comment: Comment) -> Bool {
        guard let user = checkUserSessionUseCase.execute() else { return false }
        return comment.author.uid == user.uid
    }

    func replyToComment(_ comment: Comment) {
        commentMode = .reply(comment)
        showCommentInput = true
    }

    func editComment(_ comment: Comment) {
        commentMode = .edit(comment)
        commentText = comment.content
        showCommentInput = true
    }

    func deleteComment(_ comment: Comment) {
        itemToDelete = .comment
        showDeleteDialog = true
    }

    func confirmDeleteComment() {
        // Call DeleteCommentUseCase
    }
}
