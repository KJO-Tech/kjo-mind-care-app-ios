import SwiftUI

public enum MoodRoute: Hashable {
    case createMood
}

public class MoodCoordinator: Coordinator {
    @Published public var path = NavigationPath()

    public init() {}

    public func start() {
        // Root is MoodsView
    }

    public func showCreateMood() {
        path.append(MoodRoute.createMood)
    }
}
