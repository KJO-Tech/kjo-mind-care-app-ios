import SwiftUI

@MainActor
class BlogListViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var selectedFilter: BlogFilter = .all
    @Published var blogs: [Blog] = Blog.mockList
    
    // Category filter properties
    @Published var showCategoryFilter: Bool = false
    @Published var selectedCategory: BlogCategory? = nil
    @Published var tempSelectedCategory: BlogCategory? = nil
    
    init() {}
    
    func refresh() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        blogs = Blog.mockList
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

