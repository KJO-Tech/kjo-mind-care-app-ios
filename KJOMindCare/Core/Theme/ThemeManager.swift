import Foundation
import SwiftUI

/// Global theme manager for the app
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("isDarkMode") var isDarkMode: Bool = true {
        didSet {
            objectWillChange.send()
        }
    }

    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    private init() {}
}
