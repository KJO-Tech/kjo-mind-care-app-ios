//
//  KJOMindCareApp.swift
//  KJOMindCare
//
//  Created by Yisus on 16/11/25.
//

import FirebaseCore
import SwiftUI

@main
struct KJOMindCareApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let diContainer = DIContainer.shared

    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                Group {
                    switch coordinator.currentRoute {
                    case .splash:
                        let splashVM = DIContainer.shared.container.resolve(SplashViewModel.self)!
                        SplashView(viewModel: splashVM)
                    case .welcome:
                        WelcomeView()
                    case .subscription:
                        let subVM = DIContainer.shared.container.resolve(
                            SubscriptionViewModel.self, arguments: false, coordinator)!
                        SubscriptionView(viewModel: subVM)
                    case .main:
                        MainView()
                    case .login:
                        let loginVM = DIContainer.shared.container.resolve(LoginViewModel.self)!
                        LoginView(viewModel: loginVM)
                    case .register:
                        let registerVM = DIContainer.shared.container.resolve(
                            RegisterViewModel.self)!
                        RegisterView(viewModel: registerVM)
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .splash:
                        let splashVM = DIContainer.shared.container.resolve(SplashViewModel.self)!
                        SplashView(viewModel: splashVM)
                    case .welcome:
                        WelcomeView()
                    case .login:
                        let loginVM = DIContainer.shared.container.resolve(LoginViewModel.self)!
                        LoginView(viewModel: loginVM)
                    case .register:
                        let registerVM = DIContainer.shared.container.resolve(
                            RegisterViewModel.self)!
                        RegisterView(viewModel: registerVM)
                    case .subscription:
                        let subVM = DIContainer.shared.container.resolve(
                            SubscriptionViewModel.self, arguments: false, coordinator)!
                        SubscriptionView(viewModel: subVM)
                    case .main:
                        MainView()
                    }
                }
            }
            .environmentObject(coordinator)
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
