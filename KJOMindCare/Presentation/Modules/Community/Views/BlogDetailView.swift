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
                    .foregroundColor(Color.theme.primary)
                    .background(Color.theme.surface)

                Text(title)
                    .font(.theme.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.text)
                    .padding(.horizontal)

                Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
                )
                .font(.theme.body)
                .foregroundStyle(Color.theme.textSecondary)
                .padding(.horizontal)
                .lineSpacing(5)

                Spacer()
            }
        }
        .navigationTitle("Blog")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.theme.background.ignoresSafeArea())
    }
}
