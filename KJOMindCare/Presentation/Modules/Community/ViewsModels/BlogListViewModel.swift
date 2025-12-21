import SwiftUI
import Combine

class BlogListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedFilter: BlogFilter = .all
    @Published var blogs: [Blog] = []
    
    private let getBlogPostsUseCase: GetBlogPostsUseCase
    private var cancellables = Set<AnyCancellable>()
    
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
            searchText.isEmpty ||
            blog.title.lowercased().contains(searchText.lowercased())
        }
    }
}
