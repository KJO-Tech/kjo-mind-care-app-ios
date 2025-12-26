import SwiftUI

struct CategoryFilterSheet: View {
    @ObservedObject var viewModel: BlogListViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.cancelFilter()
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Header
                    Text("Filter by Category")
                        .font(.theme.title3.bold())
                        .foregroundColor(Color.theme.text)
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    // Clear selection option
                    CategoryRadioButton(
                        category: nil,
                        isSelected: viewModel.tempSelectedCategory == nil,
                        isClearOption: true,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.tempSelectedCategory = nil
                            }
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                    // Category options
                    ForEach(viewModel.categories) { category in
                        CategoryRadioButton(
                            category: category,
                            isSelected: viewModel.tempSelectedCategory?.id == category.id,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.tempSelectedCategory = category
                                }
                            }
                        )
                        .padding(.horizontal, 24)
                        .padding(.vertical, 4)
                    }

                    // Buttons
                    HStack(spacing: 16) {
                        Button {
                            viewModel.cancelFilter()
                        } label: {
                            Text("Cancel")
                                .font(.theme.headline)
                                .foregroundColor(Color.theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }

                        Button {
                            viewModel.applyFilter()
                        } label: {
                            Text("Apply Filters")
                                .font(.theme.headline)
                                .foregroundColor(Color.theme.primaryContent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.theme.primary)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.theme.surface)
                        .shadow(color: Color.theme.shadow.opacity(0.3), radius: 20, x: 0, y: -5)
                )
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    let vm = DIContainer.shared.container.resolve(BlogListViewModel.self)!
    CategoryFilterSheet(viewModel: vm)
        .preferredColorScheme(.dark)
}
