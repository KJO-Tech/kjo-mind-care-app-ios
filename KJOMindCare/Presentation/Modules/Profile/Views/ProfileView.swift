import SwiftUI

struct ProfileView: View {

    @State private var showEdit = false

    @StateObject private var coordinator = ProfileCoordinator()
    @StateObject private var viewModel = DIContainer.shared.container.resolve(
        SettingsViewModel.self)!
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ScrollView {
                VStack(spacing: 20) {

                    // ---------- FOTO Y DATOS ----------
                    VStack(spacing: 12) {
                        if let img = viewModel.profileImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        } else if let url = viewModel.profileImageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 140, height: 140)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(Circle())
                                        .shadow(radius: 6)
                                case .failure:
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .padding(40)
                                        .frame(width: 140, height: 140)
                                        .background(Color.theme.card)
                                        .clipShape(Circle())
                                        .foregroundColor(Color.theme.textSecondary)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .id(viewModel.profileImageURL)
                        } else {
                            Circle()
                                .fill(Color.theme.card)
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(Color.theme.textSecondary)
                                )
                        }

                        if !viewModel.userName.isEmpty {
                            Text(viewModel.userName)
                                .font(.theme.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.theme.text)
                            Text(viewModel.userEmail)
                                .foregroundColor(Color.theme.textSecondary)
                                .font(.theme.subheadline)
                        } else {
                            Text("Loading...")
                                .font(.theme.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)

                    // ---------- ESTADÍSTICAS ----------
                    HStack(spacing: 16) {
                        statBox(title: "Check-ins", value: "28", systemIcon: "")
                        statBox(title: "Post", value: "14", systemIcon: "")
                        statBox(title: "Badges", value: "3", systemIcon: "")
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)

                    // ---------- SUBTITULO SETTINGS ----------
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "profile.settings.header"))
                            .font(.theme.headline)
                            .padding(.horizontal)
                            .foregroundColor(Color.theme.text)

                        VStack(spacing: 0) {

                            accountNavigationRow(
                                icon: "pencil",
                                title: String(localized: "profile.edit_profile"),
                                action: {
                                    coordinator.showEditProfile()
                                }
                            )

                            Divider()

                            accountNavigationRow(
                                icon: "checklist",
                                title: String(localized: "profile.edit_subscriptions"),
                                action: {
                                    coordinator.showSubscriptions()
                                }
                            )

                            Divider()

                            Divider()

                            // --- TOGGLE NOTIFICACIONES DIARIAS ---
                            VStack(alignment: .leading, spacing: 12) {

                                HStack {
                                    Image(systemName: "bell.badge")
                                        .foregroundColor(Color.theme.secondary)
                                        .frame(width: 24)

                                    Toggle(
                                        isOn: Binding(
                                            get: { viewModel.notificationsEnabled },
                                            set: { newValue in
                                                Task {
                                                    await viewModel.updateNotifications(
                                                        enabled: newValue,
                                                        hour: viewModel.notificationHour
                                                    )
                                                }
                                            }
                                        )
                                    ) {
                                        Text(String(localized: "profile.notifications"))
                                            .foregroundColor(Color.theme.text)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)

                                if viewModel.notificationsEnabled {

                                    HStack {
                                        Text("Hour")
                                            .font(.theme.subheadline)
                                            .foregroundColor(Color.theme.textSecondary)

                                        Spacer()

                                        DatePicker(
                                            "",
                                            selection: Binding(
                                                get: { viewModel.notificationHour },
                                                set: { newHour in
                                                    Task {
                                                        await viewModel.updateNotifications(
                                                            enabled: true,
                                                            hour: newHour
                                                        )
                                                    }
                                                }
                                            ),
                                            displayedComponents: .hourAndMinute
                                        )
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.theme.card)
                                    )
                                    .padding(.horizontal)
                                    .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut, value: viewModel.notificationsEnabled)

                            Divider()

                            // --- TOGGLE MODO OSCURO ---
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(Color.theme.primary)
                                    .frame(width: 24)

                                Toggle(
                                    isOn: Binding(
                                        get: { viewModel.darkModeEnabled },  // Local property
                                        set: { newValue in
                                            Task {
                                                await viewModel.updateDarkMode(newValue)
                                            }
                                        }
                                    )
                                ) {
                                    Text(String(localized: "profile.dark_mode"))
                                        .foregroundColor(Color.theme.text)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .background(Color.theme.card)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.top, 6)

                    // ---------- LOG OUT BUTTON FULL WIDTH + CENTERED ----------
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        HStack {
                            Spacer()  // centro

                            Image(systemName: "arrow.uturn.left.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color.theme.error)

                            Text(String(localized: "profile.logout"))
                                .font(.theme.headline)
                                .foregroundColor(Color.theme.error)

                            Spacer()  // centro
                        }
                        .padding(.vertical, 14)
                        .background(Color.theme.card)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    .shadow(radius: 1)

                }
                .padding(.vertical)
            }
            .navigationTitle(String(localized: "profile.title"))
            .navigationBarTitleDisplayMode(.large)
            .background(Color.theme.background.ignoresSafeArea())
            .onAppear {
                Task { await viewModel.loadProfile() }
            }
            // Handled via Coordinator now
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .editProfile:
                    EditProfileView(viewModel: viewModel)
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
        }
    }

    // MARK: - COMPONENTES AUXILIARES

    private func statBox(title: String, value: String, systemIcon: String) -> some View {
        VStack(spacing: 8) {
            if !systemIcon.isEmpty {
                Image(systemName: systemIcon)
                    .font(.theme.title2)
                    .foregroundColor(Color.theme.secondary)
            }
            Text(value)
                .font(.theme.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.text)
            Text(title)
                .font(.theme.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(width: 110, height: 100)
        .background(Color.theme.card)
        .cornerRadius(14)
    }

    // Renamed to conform to "use actions" instead of destinations directly
    private func accountNavigationRow(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
                    .background(Color.theme.background)
                    .cornerRadius(8)
                    .foregroundColor(Color.theme.secondary)

                Text(title)
                    .foregroundColor(Color.theme.text)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Color.theme.textSecondary)
            }
            .padding()
        }
    }

}

#Preview {
    let coordinator = AppCoordinator()
    ProfileView()
        .environmentObject(coordinator)
}
