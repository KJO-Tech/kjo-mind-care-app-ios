import SwiftUI

struct BlogListView: View {
    @StateObject var vm: BlogListViewModel
    
    init(vm: BlogListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Community Blog")
                .font(.theme.largeTitle.bold())
                .foregroundColor(Color.theme.primary)
                .padding(.top, 10)
            
            searchBar
            filterTabs
            blogList
        }
        .background(Color.background.edgesIgnoringSafeArea(.all))
        .overlay(alignment: .bottomTrailing) {
            floatingButton
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
            
            Button {} label: {
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
            ForEach(BlogFilter.allCases, id: \.self) { filter in
                VStack {
                    Button {
                        vm.selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .foregroundColor(vm.selectedFilter == filter ? Color.theme.primary : Color.theme.textSecondary)
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
            LazyVStack(spacing: 18) {
                ForEach(vm.filteredBlogs) { blog in
                    BlogCard(blog: blog)
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
            // Acción del botón
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
    BlogListView(vm: listBlogsVM)
}
