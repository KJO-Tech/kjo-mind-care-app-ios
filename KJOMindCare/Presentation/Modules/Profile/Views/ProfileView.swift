import SwiftUI

public struct ProfileView: View {
    @StateObject private var coordinator = ProfileCoordinator()

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.theme.textSecondary)
                    .padding(.top)

                Text("John Doe")
                    .font(.theme.title)
                    .fontWeight(.bold)

                Text("john.doe@example.com")
                    .foregroundColor(Color.theme.textSecondary)

                HStack(spacing: 40) {
                    VStack {
                        Text("12")
                            .font(.theme.headline)
                        Text("Moods")
                            .font(.theme.caption)
                    }
                    VStack {
                        Text("5")
                            .font(.theme.headline)
                        Text("Blogs")
                            .font(.theme.caption)
                    }
                    VStack {
                        Text("3")
                            .font(.theme.headline)
                        Text("Streak")
                            .font(.theme.caption)
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
                                .foregroundColor(Color.theme.error)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profile")
            .background(Color.theme.background.ignoresSafeArea())
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
