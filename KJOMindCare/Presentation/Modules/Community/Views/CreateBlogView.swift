import SwiftUI

public struct CreateBlogView: View {
    @EnvironmentObject var coordinator: CommunityCoordinator
    @State private var title = ""
    @State private var content = ""

    public var body: some View {
        VStack(spacing: 20) {
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextEditor(text: $content)
                .padding(5)
                .background(Color.theme.surface)
                .cornerRadius(8)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.theme.textSecondary.opacity(0.2), lineWidth: 1)
                        .padding(.horizontal)
                )

            Button(action: {
                // Save logic
                coordinator.pop()
            }) {
                Text("Publish Blog")
                    .font(.theme.headline)
                    .foregroundColor(Color.theme.primaryContent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.theme.primary)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding(.top)
        .navigationTitle("Create Blog")
        .background(Color.theme.background.ignoresSafeArea())
    }
}
