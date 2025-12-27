import SwiftUI

struct CategoryListView: View {
    @StateObject var viewModel: CategoryListViewModel
    var onCategorySelected: (String) -> Void
    var onBack: (() -> Void)? = nil

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        viewModel.fetchCategories()
                    }
                    .padding()
                    Spacer()
                }
            } else if viewModel.categories.isEmpty {
                VStack {
                    Spacer()
                    Text("No categories found.")
                        .foregroundColor(Color.theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.categories) { category in
                            CategoryCard(category: category) {
                                onCategorySelected(category.id ?? "")
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}

struct CategoryCard: View {
    let category: ActivityCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Image Placeholder or AsyncImage
                // Assuming imageUrl is valid, using placeholder for now if empty or error
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.theme.surface)  // Placeholder bg
                        .aspectRatio(1.5, contentMode: .fit)  // Aspect ratio for image area

                    if !category.imageUrl.isEmpty, let url = URL(string: category.imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.5, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "figure.mind.and.body")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.getName())
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.text)
                        .lineLimit(1)

                    Text(category.getDescription())
                        .font(.theme.caption)
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(12)
            .background(Color.theme.card)
            .cornerRadius(16)
            .shadow(color: Color.theme.shadow.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}
