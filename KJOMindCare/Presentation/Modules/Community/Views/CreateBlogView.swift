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
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .padding(.horizontal)
                )

            Button(action: {
                // Save logic
                coordinator.pop()
            }) {
                Text("Publish Blog")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding(.top)
        .navigationTitle("Create Blog")
    }
}
