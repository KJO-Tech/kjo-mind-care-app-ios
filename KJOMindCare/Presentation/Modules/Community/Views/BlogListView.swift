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
        .onAppear {
            // Refresh when returning from other screens
            if !coordinator.path.isEmpty {
                // Only refresh if we came back from somewhere
                Task {
                    await vm.refresh()
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            floatingButton
        }
        .overlay {
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
        .sheet(isPresented: $vm.showCategoryFilter) {
            CategoryFilterSheet(viewModel: vm)
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
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Invisible anchor at the top for scrolling
                    Color.clear
                        .frame(height: 1)
                        .id("topAnchor")
                    
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
            .onChange(of: vm.selectedFilter) { _ in
                withAnimation {
                    proxy.scrollTo("topAnchor", anchor: .top)
                }
            }
            .refreshable {
                await vm.refresh()
            }
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
