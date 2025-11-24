import SwiftUI

struct BlogDetailView: View {
    let title: String

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "book.fill")  // Placeholder
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .background(Color.gray.opacity(0.1))

                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
                )
                .font(.body)
                .padding(.horizontal)
                .lineSpacing(5)

                Spacer()
            }
        }
        .navigationTitle("Blog")
        .navigationBarTitleDisplayMode(.inline)
    }
}
