import SwiftUI

public enum HomeRoute: Hashable {
    case categoryDetail(String)  // Passing category name for now
    case exerciseDetail(String)  // Passing exercise name for now
}

public class HomeCoordinator: Coordinator {
    @Published public var path = NavigationPath()

    public init() {}

    public func start() {
        // Home is the root, no action needed for start usually unless deep linking
    }

    public func showCategoryDetail(category: String) {
        path.append(HomeRoute.categoryDetail(category))
    }

    public func showExerciseDetail(exercise: String) {
        path.append(HomeRoute.exerciseDetail(exercise))
    }
}
