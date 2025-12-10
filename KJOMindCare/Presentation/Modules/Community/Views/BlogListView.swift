import SwiftUI

struct BlogListView: View {
    @StateObject var vm: BlogListViewModel

    init(vm: BlogListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Community Blog")
                .font(.largeTitle.bold())
                .foregroundColor(Color.text)
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
                    .foregroundColor(Color.textSecondary)
                
                TextField("Search blogs...", text: $vm.searchText)
                    .foregroundColor(Color.text)
            }
            .padding(12)
            .background(Color.backgroundAlt)
            .cornerRadius(14)
            
            Button {} label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(Color.text)
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
                            .foregroundColor(vm.selectedFilter == filter ? Color.primary : Color.textSecondary)
                    }
                    
                    Rectangle()
                        .fill(vm.selectedFilter == filter ? Color.primary : Color.clear)
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
                    .fill(Color.primarySoft)
                    .frame(width: 65, height: 65)
                    .shadow(color: Color.primary.opacity(0.7), radius: 8)
                
                Image(systemName: "plus")
                    .foregroundColor(Color.primary)
                    .font(.title)
            }
            .padding()
        }
    }
}


#Preview {
    let listBlogsVM = DIContainer.shared.container.resolve(BlogListViewModel.self)!
    BlogListView(vm: listBlogsVM)
}
