import SwiftUI

public enum CommunityRoute: Hashable {
    case blogDetail(String)
    case createBlog
}

public class CommunityCoordinator: Coordinator {
    @Published public var path = NavigationPath()

    public init() {}

    public func start() {
        // Root is BlogListView
    }

    public func showBlogDetail(blogTitle: String) {
        path.append(CommunityRoute.blogDetail(blogTitle))
    }

    public func showCreateBlog() {
        path.append(CommunityRoute.createBlog)
    }
}
