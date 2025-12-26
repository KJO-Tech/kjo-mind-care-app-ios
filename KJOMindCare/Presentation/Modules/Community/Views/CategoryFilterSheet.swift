import SwiftUI

struct CategoryFilterSheet: View {
    @ObservedObject var viewModel: BlogListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // All Categories option
                Button {
                    viewModel.tempSelectedCategory = nil
                } label: {
                    HStack {
                        Text("All Categories")
                            .foregroundColor(Color.theme.text)
                        Spacer()
                        if viewModel.tempSelectedCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.theme.primary)
                        }
                    }
                    .padding()
                    .background(Color.theme.card)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Categories list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.categories) { category in
                            Button {
                                viewModel.tempSelectedCategory = category
                            } label: {
                                HStack {
                                    Text(category.getLocalizedName(languageCode: Locale.current.language.languageCode?.identifier ?? "en"))
                                        .foregroundColor(Color.theme.text)
                                    Spacer()
                                    if viewModel.tempSelectedCategory?.id == category.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color.theme.primary)
                                    }
                                }
                                .padding()
                                .background(Color.theme.card)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        viewModel.cancelFilter()
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.theme.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.textSecondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Button {
                        viewModel.applyFilter()
                        dismiss()
                    } label: {
                        Text("Apply")
                            .font(.headline)
                            .foregroundColor(Color.theme.primaryContent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.theme.primary)
                            )
                    }
                }
                .padding()
                .background(Color.theme.background)
            }
            .background(Color.theme.background)
            .navigationTitle("Filter by Category")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
