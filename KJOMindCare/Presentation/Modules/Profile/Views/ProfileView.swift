import SwiftUI

public struct ProfileView: View {
    @StateObject private var coordinator = ProfileCoordinator()

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.top)

                Text("John Doe")
                    .font(.title)
                    .fontWeight(.bold)

                Text("john.doe@example.com")
                    .foregroundColor(.gray)

                HStack(spacing: 40) {
                    VStack {
                        Text("12")
                            .font(.headline)
                        Text("Moods")
                            .font(.caption)
                    }
                    VStack {
                        Text("5")
                            .font(.headline)
                        Text("Blogs")
                            .font(.caption)
                    }
                    VStack {
                        Text("3")
                            .font(.headline)
                        Text("Streak")
                            .font(.caption)
                    }
                }
                .padding()

                List {
                    Section(header: Text("Settings")) {
                        Button(action: {
                            coordinator.showEditProfile()
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                        }

                        HStack {
                            Image(systemName: "bell")
                            Toggle("Notifications", isOn: .constant(true))
                        }

                        HStack {
                            Image(systemName: "lock")
                            Text("Privacy Policy")
                        }
                    }

                    Section {
                        Button(action: {
                            // Logout logic
                        }) {
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .editProfile:
                    EditProfileView()
                        .environmentObject(coordinator)
                }
            }
        }
    }
}
