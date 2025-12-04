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
                .foregroundColor(.white)
                .padding(.top, 10)
            
            searchBar
            filterTabs
            blogList
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
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
                    .foregroundColor(.gray)
                
                TextField("Search blogs...", text: $vm.searchText)
                    .foregroundColor(.white)
            }
            .padding(12)
            .background(Color.white.opacity(0.08))
            .cornerRadius(14)
            
            Button {} label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(.white)
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
                            .foregroundColor(vm.selectedFilter == filter ? .purple : .gray)
                    }
                    
                    Rectangle()
                        .fill(vm.selectedFilter == filter ? Color.purple : .clear)
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
            
        } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 65, height: 65)
                    .shadow(color: .purple.opacity(0.7), radius: 8)
                
                Image(systemName: "plus")
                    .foregroundColor(.purple)
                    .font(.title)
            }
            .padding()
        }
    }
}


#Preview {
    let vm = BlogListViewModel()
    BlogListView(vm: vm)
        .preferredColorScheme(.dark)
}
