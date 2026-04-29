import SwiftUI

enum HomeRoute: Hashable {
    case categoryList
    case categoryDetail(String)
    case exerciseDetail(String)
    case recordMood(String?)  // Passing selected mood ID (optional)
}

public class HomeCoordinator: Coordinator {
    @Published public var path = NavigationPath()

    public init() {}

    public func start() {
        // Home is the root, no action needed for start usually unless deep linking
    }

    public func showCategoryList() {
        path.append(HomeRoute.categoryList)
    }

    public func showCategoryDetail(categoryId: String) {
        path.append(HomeRoute.categoryDetail(categoryId))
    }

    public func showExerciseDetail(exerciseId: String) {
        path.append(HomeRoute.exerciseDetail(exerciseId))
    }

    public func showRecordMood(moodId: String?) {
        path.append(HomeRoute.recordMood(moodId))
    }

    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
