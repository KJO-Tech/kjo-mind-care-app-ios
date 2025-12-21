import SwiftUI
import Combine

class BlogListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedFilter: BlogFilter = .all
    @Published var blogs: [Blog] = []
    
    private let getBlogPostsUseCase: GetBlogPostsUseCase
    private var cancellables = Set<AnyCancellable>()
    // Category filter properties
    @Published var showCategoryFilter: Bool = false
    @Published var selectedCategory: BlogCategory? = nil
    @Published var tempSelectedCategory: BlogCategory? = nil
    
    init() {}
    
    init(getBlogPostsUseCase: GetBlogPostsUseCase) {
        self.getBlogPostsUseCase = getBlogPostsUseCase
        loadBlogs()
    }
    
    func loadBlogs() {
        getBlogPostsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading blogs: \(error)")
                }
            } receiveValue: { [weak self] blogs in
                self?.blogs = blogs
            }
            .store(in: &cancellables)
    }
    

    func refresh() async {
        loadBlogs()
    }

    var filteredBlogs: [Blog] {
        blogs.filter { blog in

            let matchesSearch = searchText.isEmpty ||
                blog.title.lowercased().contains(searchText.lowercased()) ||
                blog.content.lowercased().contains(searchText.lowercased())
            
            let matchesCategory = selectedCategory == nil || blog.category == selectedCategory
            
            return matchesSearch && matchesCategory
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
}

