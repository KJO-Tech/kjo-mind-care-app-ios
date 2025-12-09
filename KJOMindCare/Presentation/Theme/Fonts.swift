import SwiftUI

public extension Font {
    
    struct Theme {
        // Headings
        public static let largeTitle = AppTheme.Fonts.largeTitle
        public static let title = AppTheme.Fonts.title
        public static let title2 = AppTheme.Fonts.title2
        public static let title3 = AppTheme.Fonts.title3
        public static let headline = AppTheme.Fonts.headline
        public static let subheadline = AppTheme.Fonts.subheadline
        
        // Body
        public static let body = AppTheme.Fonts.body
        public static let callout = AppTheme.Fonts.callout
        public static let footnote = AppTheme.Fonts.footnote
        public static let caption = AppTheme.Fonts.caption
        public static let caption2 = AppTheme.Fonts.caption2
        
        // Custom
        public static let logo = AppTheme.Fonts.logo
    }
    
    static let theme = Theme.self
}
