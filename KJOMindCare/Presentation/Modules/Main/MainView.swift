import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, mood, community, profile
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView()
                case .mood:
                    MoodListView()
                case .community:
                    BlogListView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
            .padding(.bottom, 30)  // Adjust for safe area
            .background(Color.white)  // Or your app's background color
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
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
                    .foregroundColor(isSelected ? .primaryLight : .gray)  // Use custom color

                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primaryLight : .gray)
            }
        }
    }
}

#Preview {
    MainView()
}
