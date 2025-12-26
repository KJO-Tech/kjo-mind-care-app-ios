import SwiftUI

public enum CommunityRoute: Hashable {
    case blogDetail(String)
    case createBlog
    case editBlog(String)  // Blog ID instead of Blog object
}

public class CommunityCoordinator: Coordinator {
    @Published public var path = NavigationPath()

    public init() {}

    public func start() {
        // Root is BlogListView
    }

    public func showBlogDetail(blogId: String) {
        path.append(CommunityRoute.blogDetail(blogId))
    }

    public func showCreateBlog() {
        path.append(CommunityRoute.createBlog)
    }

    func showEditBlog(blog: Blog) {
        path.append(CommunityRoute.editBlog(blog.id))
    }

    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
