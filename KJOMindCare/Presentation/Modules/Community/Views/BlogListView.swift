import SwiftUI

public struct BlogListView: View {
    @StateObject private var coordinator = CommunityCoordinator()
    @State private var selectedFilter = 0

    let filters = ["Recent", "Popular", "My Blogs"]
    let blogs = [
        "Understanding Anxiety", "Benefits of Meditation", "Healthy Sleep Habits",
        "Mindfulness 101",
    ]

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(0..<filters.count, id: \.self) { index in
                        Text(filters[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List(blogs, id: \.self) { blog in
                    Button(action: {
                        coordinator.showBlogDetail(blogTitle: blog)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(blog)
                                    .font(.headline)
                                Text("Read more about this topic...")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.showCreateBlog()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: CommunityRoute.self) { route in
                switch route {
                case .blogDetail(let title):
                    BlogDetailView(title: title)
                        .environmentObject(coordinator)
                case .createBlog:
                    CreateBlogView()
                        .environmentObject(coordinator)
                }
            }
        }
    }
}
