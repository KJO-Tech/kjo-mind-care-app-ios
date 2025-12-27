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
    var localizedTitle: String {
        switch self {
        case .all:
            return String(localized: "community.filter.all")
        case .latest:
            return String(localized: "community.filter.latest")
        case .popular:
            return String(localized: "community.filter.popular")
        case .myBlogs:
            return String(localized: "community.filter.myBlogs")
        case .category:
            return "" // Not used in tabs
        }
    }
}
