import SwiftUI

public enum HomeRoute: Hashable {
    case categoryDetail(String)  // Passing category name for now
    case exerciseDetail(String)  // Passing exercise name for now
    case recordMood(String?)  // Passing selected mood ID (optional)
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

    public func showRecordMood(moodId: String?) {
        path.append(HomeRoute.recordMood(moodId))
    }
}
