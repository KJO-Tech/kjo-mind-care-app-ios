import SwiftUI

struct SubscriptionView: View {
    @StateObject var viewModel: SubscriptionViewModel

    init(viewModel: SubscriptionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // Grid columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Back button only in Edit Mode)
                if viewModel.isEditMode {
                    HStack {
                        Spacer()
                        Text("subscription.title")
                            .font(.theme.headline)
                            .foregroundColor(Color.theme.text)
                        Spacer()
                    }
                } else {
                    // Onboarding Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("subscription.title")
                            .font(.theme.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.text)

                        Text("subscription.subtitle")
                            .font(.theme.body)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .padding(.top, 20)
                }

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        viewModel.loadData()
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.categories) { category in
                                CategorySelectCard(
                                    category: category,
                                    isSelected: viewModel.selectedCategoryIds.contains(
                                        category.id ?? ""),
                                    onTap: {
                                        if let id = category.id {
                                            viewModel.toggleCategory(id: id)
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }

                // Footer
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.save()
                    }) {
                        Text("subscription.save")
                            .font(.theme.headline)
                            .foregroundColor(Color.theme.primaryContent)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.primary)
                            .cornerRadius(12)  // Consistent radius
                    }
                    .disabled(viewModel.isLoading)

                    if !viewModel.isEditMode {
                        Button(action: {
                            viewModel.skip()
                        }) {
                            Text("subscription.skip")
                                .font(.theme.body)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
                .padding()
                .background(Color.theme.background)  // Ensure footer has background
            }
        }
    }
}

struct CategorySelectCard: View {
    let category: ActivityCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Background
                Color.theme.surface
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                // Content
                VStack {
                    Spacer()
                    // Central Emoji Image
                    if let url = URL(string: category.imageUrl), !category.imageUrl.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            case .failure:
                                Image(systemName: "star.fill")  // Fallback
                                    .font(.system(size: 30))
                                    .foregroundColor(Color.theme.primary)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "star.fill")  // Fallback
                            .font(.system(size: 30))
                            .foregroundColor(Color.theme.primary)
                    }
                    Spacer()

                    // Name
                    Text(category.getName())
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

                // Selection Indicator (Top Right)
                VStack {
                    HStack {
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color.theme.primary)
                                .background(Circle().fill(Color.white))
                        } else {
                            Image(systemName: "circle")
                                .font(.title3)
                                .foregroundColor(Color.theme.textSecondary.opacity(0.5))
                        }
                    }
                    Spacer()
                }
                .padding(12)
            }
            .frame(height: 140)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}
