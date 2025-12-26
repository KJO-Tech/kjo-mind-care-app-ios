import Combine
import SwiftUI

class BlogListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedFilter: BlogFilter = .all
    @Published private var allBlogs: [Blog] = []
    @Published var isLoading: Bool = false

    private let getBlogPostsUseCase: GetBlogPostsUseCase
    private let checkUserSessionUseCase: CheckUserSessionUseCase
    private let toggleLikeUseCase: ToggleLikeUseCase
    private let getCategoriesUseCase: GetCategoriesUseCase

    private var cancellables = Set<AnyCancellable>()

    // Category filter properties
    @Published var categories: [Category] = []
    @Published var showCategoryFilter: Bool = false
    @Published var selectedCategory: Category? = nil
    @Published var tempSelectedCategory: Category? = nil

    init(
        getBlogPostsUseCase: GetBlogPostsUseCase,
        checkUserSessionUseCase: CheckUserSessionUseCase,
        toggleLikeUseCase: ToggleLikeUseCase,
        getCategoriesUseCase: GetCategoriesUseCase
    ) {
        self.getBlogPostsUseCase = getBlogPostsUseCase
        self.checkUserSessionUseCase = checkUserSessionUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
        self.getCategoriesUseCase = getCategoriesUseCase

        loadCategories()

        // Initial load
        loadBlogs()
    }

    func loadCategories() {
        getCategoriesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading categories: \(error)")
                }
            } receiveValue: { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
    }

    func loadBlogs(filter: BlogFilter? = nil) {
        isLoading = true
        // Always fetch all blogs (no filter passed to repository)
        getBlogPostsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading blogs: \(error)")
                }
            } receiveValue: { [weak self] blogs in
                guard let self = self else { return }

                // Store all blogs - filtering and sorting happens in computed property
                self.allBlogs = blogs
            }
            .store(in: &cancellables)
    }

    func refresh() async {
        loadBlogs()
    }

    // Computed property for filtered and sorted blogs
    var filteredBlogs: [Blog] {
        let userId = checkUserSessionUseCase.execute()?.uid ?? ""

        // Start with all blogs
        var filtered = allBlogs

        // 1. Apply search text filter
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let searchLower = searchText.lowercased()
            filtered = filtered.filter { blog in
                blog.title.lowercased().contains(searchLower)
                    || blog.content.lowercased().contains(searchLower)
                    || blog.author.fullName.lowercased().contains(searchLower)
            }
        }

        // 2. Apply category filter if selected
        if let categoryId = selectedCategory?.id {
            filtered = filtered.filter { $0.categoryId == categoryId }
        }

        // 3. Apply tab filter (My Blogs)
        if selectedFilter == .myBlogs {
            filtered = filtered.filter { $0.author.uid == userId }
        }

        // 4. Apply sorting based on selected filter
        switch selectedFilter {
        case .popular:
            return filtered.sorted { $0.likes > $1.likes }
        case .latest:
            return filtered.sorted { $0.createdAt.seconds > $1.createdAt.seconds }
        case .all, .myBlogs:
            // Use database order (already sorted by createdAt desc)
            return filtered
        default:
            return filtered
        }
    }

    func openCategoryFilter() {
        tempSelectedCategory = selectedCategory
        showCategoryFilter = true
    }

    func applyFilter() {
        selectedCategory = tempSelectedCategory
        showCategoryFilter = false
    }

    func cancelFilter() {
        tempSelectedCategory = selectedCategory
        showCategoryFilter = false
    }

    func clearFilter() {
        selectedCategory = nil
        tempSelectedCategory = nil
    }

    func toggleLike(blog: Blog) {
        guard let user = checkUserSessionUseCase.execute() else { return }

        // Optimistic update
        if let index = allBlogs.firstIndex(where: { $0.id == blog.id }) {
            var updatedBlog = allBlogs[index]
            let wasLiked = updatedBlog.isLiked
            updatedBlog.isLiked = !wasLiked
            updatedBlog.likes += (wasLiked ? -1 : 1)
            allBlogs[index] = updatedBlog
        }

        Task {
            do {
                let _ = try await toggleLikeUseCase.execute(blogId: blog.id, userId: user.uid)
                // No need to refresh entire list, as optimistic update handles UI.
                // Backend update ensures consistency for next load.
            } catch {
                // Revert on error
                print("Error toggling like: \(error)")
                if let index = allBlogs.firstIndex(where: { $0.id == blog.id }) {
                    var revertedBlog = allBlogs[index]
                    revertedBlog.isLiked = !revertedBlog.isLiked  // Revert liked status
                    revertedBlog.likes += (revertedBlog.isLiked ? 1 : -1)  // Revert count
                    allBlogs[index] = revertedBlog
                }
            }
        }
    }
}
