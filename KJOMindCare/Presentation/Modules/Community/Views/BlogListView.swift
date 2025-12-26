import SwiftUI

struct BlogListView: View {
    @ObservedObject var vm: BlogListViewModel
    @EnvironmentObject var coordinator: CommunityCoordinator

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if vm.selectedCategory != nil || vm.selectedFilter != .all {
                HStack {
                    Spacer()
                    Button("Clear Filters") {
                        vm.selectedFilter = .all
                        vm.clearFilter()
                    }
                    .font(.caption)
                    .foregroundColor(Color.theme.primary)
                    .padding(.horizontal)
                }
            }

            filterTabs
            blogList
        }
        .navigationTitle("Community")
        .background(Color.background.edgesIgnoringSafeArea(.all))
        .overlay(alignment: .bottomTrailing) {
            floatingButton
        }
        .overlay {
            if vm.showCategoryFilter {
                CategoryFilterSheet(viewModel: vm)
            }
        }
    }
}

extension BlogListView {
    var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.theme.textSecondary)

                TextField("Search blogs...", text: $vm.searchText)
                    .foregroundColor(Color.theme.text)
            }
            .padding(12)
            .background(Color.theme.card)
            .cornerRadius(14)

            Button {
                vm.openCategoryFilter()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.theme.title3)
                    .foregroundColor(Color.theme.text)
            }
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

extension BlogListView {
    var filterTabs: some View {
        HStack {
            ForEach(BlogFilter.tabs, id: \.self) { filter in
                VStack {
                    Button {
                        vm.selectedFilter = filter
                    } label: {
                        Text(filter.title)
                            .foregroundColor(
                                vm.selectedFilter == filter
                                    ? Color.theme.primary : Color.theme.textSecondary)
                    }

                    Rectangle()
                        .fill(vm.selectedFilter == filter ? Color.theme.primary : Color.clear)
                        .frame(height: 3)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
}

extension BlogListView {
    var blogList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.filteredBlogs) { blog in
                    Button {
                        coordinator.showBlogDetail(blogId: blog.id)
                    } label: {
                        BlogCard(
                            blog: blog,
                            categoryName: vm.categories.first(where: { $0.id == blog.categoryId })?
                                .getLocalizedName(
                                    languageCode: Locale.current.language.languageCode?.identifier
                                        ?? "en"),
                            onLike: {
                                vm.toggleLike(blog: blog)
                            },
                            onShare: {
                                let shareText = "Check out this blog: \(blog.title)"
                                let shareUrl = URL(
                                    string:
                                        "https://kjomindcare.netlify.app/app/community/post/\(blog.id)"
                                )!
                                let activityVC = UIActivityViewController(
                                    activityItems: [shareText, shareUrl], applicationActivities: nil
                                )

                                if let windowScene = UIApplication.shared.connectedScenes.first
                                    as? UIWindowScene,
                                    let rootVC = windowScene.windows.first?.rootViewController
                                {
                                    // Present sharing needs a VC or SwiftUI equivalent wrapper.
                                    // For simplicity in pure SwiftUI without helper, we might use ShareLink in iOS 16+
                                    // Since target is likely iOS 16+, let's check. If not, this VC logic is complex in SwiftUI view directly.
                                    // Let's use a simpler approach if possible or just print for now as "Share implementation".
                                    // Actually, UIActivityViewController presentation from View needs a wrapper.
                                    // Let's use ShareLink if available (iOS 16+).
                                    // Assuming iOS 16 based on "NavigationStack".
                                    // But BlogCard is inside a Button, so ShareLink might not be tappable if not Borderless.
                                    // Since I used BorderlessButtonStyle in BlogCard, it should work.
                                    rootVC.present(activityVC, animated: true)
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .refreshable {
            await vm.refresh()
        }
    }
}

extension BlogListView {
    var floatingButton: some View {
        Button {
            coordinator.showCreateBlog()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.theme.primary)
                    .frame(width: 65, height: 65)
                    .shadow(color: Color.primary.opacity(0.7), radius: 8)

                Image(systemName: "plus")
                    .foregroundColor(Color.theme.primaryContent)
                    .font(.theme.title)
            }
            .padding()
        }
    }
}

#Preview {
    let listBlogsVM = DIContainer.shared.container.resolve(BlogListViewModel.self)!
    let coordinator = CommunityCoordinator()

    BlogListView(vm: listBlogsVM)
        .environmentObject(coordinator)
}
