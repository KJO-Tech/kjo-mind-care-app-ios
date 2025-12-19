import SwiftUI

@MainActor
class BlogListViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var selectedFilter: BlogFilter = .all
    @Published var blogs: [Blog] = []
    
    init() {}
    
    func refresh() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        blogs = []
    }
    
    var filteredBlogs: [Blog] {
        blogs.filter { blog in
            searchText.isEmpty ||
            blog.title.lowercased().contains(searchText.lowercased())
        }
    }
}
