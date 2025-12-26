import SwiftUI

struct CommunityCoordinatorView: View {
    @StateObject private var coordinator = CommunityCoordinator()
    let blogListViewModel: BlogListViewModel

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            BlogListView(vm: blogListViewModel)
                .navigationDestination(for: CommunityRoute.self) { route in
                    switch route {
                    case .blogDetail(let blogId):
                        let vm = DIContainer.shared.container.resolve(
                            BlogDetailViewModel.self, argument: blogId)!
                        BlogDetailView(viewModel: vm)
                            .environmentObject(coordinator)
                    case .createBlog:
                        let vm = DIContainer.shared.container.resolve(CreateBlogViewModel.self)!
                        CreateBlogView(vm: vm)
                            .environmentObject(coordinator)
                    case .editBlog(let blogId):
                        EditBlogWrapper(blogId: blogId)
                            .environmentObject(coordinator)
                    }
                }
        }
        .environmentObject(coordinator)
    }
}

// Wrapper view to load blog data before showing edit form
private struct EditBlogWrapper: View {
    let blogId: String
    @EnvironmentObject var coordinator: CommunityCoordinator
    @State private var blog: Blog?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading blog...")
            } else if let blog = blog {
                let vm = DIContainer.shared.container.resolve(CreateBlogViewModel.self)!
                CreateBlogView(vm: vm)
                    .environmentObject(coordinator)
                    .onAppear {
                        vm.loadBlogForEditing(blog)
                    }
            } else {
                Text("Blog not found")
            }
        }
        .task {
            await loadBlog()
        }
    }

    private func loadBlog() async {
        let blogDetailVM = DIContainer.shared.container.resolve(
            BlogDetailViewModel.self, argument: blogId)!
        await blogDetailVM.loadBlog()
        await MainActor.run {
            self.blog = blogDetailVM.blog
            self.isLoading = false
        }
    }
}
