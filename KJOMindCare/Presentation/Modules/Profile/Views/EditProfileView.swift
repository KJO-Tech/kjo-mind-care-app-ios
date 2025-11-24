import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    @State private var name = "John Doe"
    @State private var bio = "Mental health enthusiast."

    public var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $name)
                TextField("Bio", text: $bio)
            }

            Section {
                Button(action: {
                    // Save logic
                    coordinator.pop()
                }) {
                    Text("Save Changes")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}
