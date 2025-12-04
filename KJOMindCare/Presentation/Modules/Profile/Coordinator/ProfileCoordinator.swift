import SwiftUI

public enum ProfileRoute: Hashable {
    case editProfile
}

public class ProfileCoordinator: Coordinator {
    @Published public var path = NavigationPath()

    public init() {}

    public func start() {
        // Root is ProfileView
    }

    public func showEditProfile() {
        path.append(ProfileRoute.editProfile)
    }
}
