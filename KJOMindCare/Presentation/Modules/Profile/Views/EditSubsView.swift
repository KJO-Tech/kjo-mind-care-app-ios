import SwiftUI

struct EditSubsView: View {

    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {

            Text("Choose your interests")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.subscriptions) { item in
                    SubscriptionCard(
                        item: item,
                        isSelected: viewModel.selectedSubscriptions.contains(item)
                    ) {
                        viewModel.toggleSubscription(item)
                    }
                }
            }
            .padding()

            Spacer()

            Button {
                Task {
                    await viewModel.saveSubscriptions()   
                    dismiss()
                }
            } label: {
                Text("Save")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

