import SwiftUI

struct CategoryFilterSheet: View {
    @ObservedObject var viewModel: BlogListViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Header
                    Text("Filter by Category")
                        .font(.title3.bold())
                        .foregroundColor(.white)
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
                    ForEach(BlogCategory.allCases) { category in
                        CategoryRadioButton(
                            category: category,
                            isSelected: viewModel.tempSelectedCategory == category,
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
                                .font(.headline)
                                .foregroundColor(.purple)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        
                        Button {
                            viewModel.applyFilter()
                        } label: {
                            Text("Apply Filters")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.purple)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(white: 0.15))
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                )
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    CategoryFilterSheet(viewModel: BlogListViewModel())
        .preferredColorScheme(.dark)
}
