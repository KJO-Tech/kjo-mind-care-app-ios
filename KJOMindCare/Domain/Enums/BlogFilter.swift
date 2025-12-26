import Foundation

enum BlogFilter: Equatable, Hashable {
    case all
    case latest
    case popular
    case category(String)
    case myBlogs
    
    // Tabs to display in UI (excluding dynamic categories)
    static let tabs: [BlogFilter] = [.all, .latest, .popular, .myBlogs]
    
    // Helper for UI tabs handles title display
    var title: String {
        switch self {
        case .all: return "All"
        case .latest: return "Latest"
        case .popular: return "Popular"
        case .category: return "Category"
        case .myBlogs: return "My Blogs"
        }
    }
}
