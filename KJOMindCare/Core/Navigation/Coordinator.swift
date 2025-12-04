import SwiftUI

// MARK: - Coordinator Protocol
// MARK: - Coordinator Protocol
public protocol Coordinator: ObservableObject {
    var path: NavigationPath { get set }
    func start()
    func pop()
    func popToRoot()
}

extension Coordinator {
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    public func popToRoot() {
        path = NavigationPath()
    }
}

// MARK: - App Coordinator
public enum AppRoute: Hashable {
    case splash
    case welcome
    case login
    case register
    case subscription
    case main
}

public class AppCoordinator: Coordinator {
    @Published public var path = NavigationPath()
    @Published public var currentRoute: AppRoute = .splash

    public init() {
        self.currentRoute = .splash
    }

    public func start() {
        // Initial logic if needed
        self.currentRoute = .splash
    }

    // MARK: - Navigation Methods

    public func showWelcome() {
        self.currentRoute = .welcome
    }

    public func showLogin() {
        self.path.append(AppRoute.login)
    }

    public func showRegister() {
        self.path.append(AppRoute.register)
    }

    public func showSubscription() {
        // Reset path to ensure clean state if coming from deep in stack, or just append
        // For this flow, we might want to replace the root or push.
        // Let's assume we want to clear the auth stack and show subscription
        self.path = NavigationPath()
        self.currentRoute = .subscription
    }

    public func showMain() {
        self.path = NavigationPath()
        self.currentRoute = .main
    }

    public func navigateTo(_ route: AppRoute) {
        path.append(route)
    }

    // pop and popToRoot are handled by protocol extension default implementation
}
