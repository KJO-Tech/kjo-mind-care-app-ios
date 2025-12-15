import SwiftUI

public struct ProfileView: View {
    @StateObject private var coordinator = ProfileCoordinator()
    @StateObject private var viewModel = DIContainer.shared.container.resolve(
        ProfileViewModel.self)!
    @EnvironmentObject var appCoordinator: AppCoordinator

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

                        Button(action: {
                            coordinator.showSubscriptions()
                        }) {
                            HStack {
                                Image(systemName: "checklist")
                                Text("Edit Subscriptions")
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
                            viewModel.signOut()
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
                case .subscriptions:
                    if let subscriptionVM = DIContainer.shared.container.resolve(
                        SubscriptionViewModel.self, arguments: true, appCoordinator)
                    {
                        // Handle back navigation for Profile flow
                        let _ =
                            subscriptionVM.onDismiss = {
                                coordinator.pop()
                            }
                        SubscriptionView(viewModel: subscriptionVM)
                    } else {
                        Text("Error resolving SubscriptionViewModel")
                    }
                }
            }
            .onChange(of: viewModel.isSignedOut) { signedOut in
                if signedOut {
                    appCoordinator.logout()
                }
            }
            .alert(
                isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in viewModel.errorMessage = nil }
                )
            ) {
                Alert(
                    title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")))
            }
        }
    }
}
