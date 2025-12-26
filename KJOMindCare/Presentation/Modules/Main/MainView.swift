import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, mood, community, profile
    }

    @StateObject private var homeViewModel = DIContainer.shared.container.resolve(
        HomeViewModel.self)!
    @StateObject private var moodsViewModel = DIContainer.shared.container.resolve(
        MoodsViewModel.self)!
    @StateObject private var blogListViewModel = DIContainer.shared.container.resolve(
        BlogListViewModel.self)!
    @StateObject private var settingsViewModel = DIContainer.shared.container.resolve(
        SettingsViewModel.self)!

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView(viewModel: homeViewModel)
                case .mood:
                    MoodsView(viewModel: moodsViewModel)
                case .community:
                    CommunityCoordinatorView(blogListViewModel: blogListViewModel)
                case .profile:
                    ProfileView(viewModel: settingsViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.theme.background.ignoresSafeArea())
            .font(Font.theme.body)

            // Custom Tab Bar
            HStack {
                Spacer()

                TabBarItem(iconName: "house", title: "Home", isSelected: selectedTab == .home) {
                    selectedTab = .home
                }

                Spacer()

                TabBarItem(
                    iconName: "face.smiling", title: "Mood", isSelected: selectedTab == .mood
                ) {
                    selectedTab = .mood
                }

                Spacer()

                TabBarItem(
                    iconName: "person.3", title: "Community", isSelected: selectedTab == .community
                ) {
                    selectedTab = .community
                }

                Spacer()

                TabBarItem(
                    iconName: "person", title: "Profile", isSelected: selectedTab == .profile
                ) {
                    selectedTab = .profile
                }

                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 5)  // Adjust for safe area
            .background(Color.theme.surface)  // Or your app's background color
            .shadow(color: Color.theme.shadow.opacity(0.3), radius: 5, x: 0, y: -5)
        }
        .ignoresSafeArea(.keyboard)  // Prevent tab bar from moving up with keyboard if needed
    }
}

struct TabBarItem: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? iconName + ".fill" : iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .theme.primary : .theme.textSecondary)  // Use custom color

                Text(title)
                    .font(.theme.caption)
                    .foregroundColor(isSelected ? .theme.primary : .theme.textSecondary)
            }
        }
    }
}

#Preview {
    MainView()
}
