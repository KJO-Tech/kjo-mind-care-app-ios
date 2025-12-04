//
//  KJOMindCareApp.swift
//  KJOMindCare
//
//  Created by Yisus on 16/11/25.
//

import SwiftUI
import FirebaseCore

@main
struct KJOMindCareApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let diContainer = DIContainer.shared

    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                Group {
                    switch coordinator.currentRoute {
                    case .splash:
                        SplashView()
                    case .welcome:
                        WelcomeView()
                    case .subscription:
                        SubscriptionView()
                    case .main:
                        MainView()
                    case .login, .register:
                        // These are typically pushed, but if we land here as root (unlikely with current logic), show empty or fallback
                        EmptyView()
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .splash:
                        SplashView()
                    case .welcome:
                        WelcomeView()
                    case .login:
                        let loginVM = DIContainer.shared.container.resolve(LoginViewModel.self)!
                        LoginView(viewModel: loginVM)
                    case .register:
                        let registerVM = DIContainer.shared.container.resolve(RegisterViewModel.self)!
                        RegisterView(viewModel: registerVM)
                    case .subscription:
                        SubscriptionView()
                    case .main:
                        MainView()
                    }
                }
            }
            .environmentObject(coordinator)
        }
    }
}
