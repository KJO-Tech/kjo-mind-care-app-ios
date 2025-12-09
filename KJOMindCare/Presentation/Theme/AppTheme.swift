import SwiftUI

public struct AppTheme {
    
    // MARK: - Colors
    /// Centralized access to the app's color palette.
    public struct Colors {
        // Brand Identity
        static let primary = Color("Primary")
        static let primaryContent = Color("PrimaryContent")
        static let secondary = Color("Secondary")
        static let secondaryContent = Color("SecondaryContent")
        static let accent = Color("Accent")
        static let accentContent = Color("AccentContent")
        
        // Backgrounds
        static let background = Color("Background")
        static let card = Color("Card")
        static let surface = Color("Surface")
        
        // Text
        static let text = Color("Text")
        static let textSecondary = Color("TextSecondary")
        
        // Feedback
        static let info = Color("Info")
        static let infoContent = Color("InfoContent")
        static let success = Color("Success")
        static let successContent = Color("SuccessContent")
        static let error = Color("Error")
        static let errorContent = Color("ErrorContent")
        static let warning = Color("Warning")
        static let warningContent = Color("WarningContent")

        // Other
        static let divider = Color("Divider")
        static let border = Color("Border")
        static let shadow = Color("Shadow")
    }
    
    // MARK: - Fonts
    /// Centralized typography styles using custom fonts.
    /// Requires "Poppins" and "Inter" fonts to be added to the project.
    public struct Fonts {
        
        // MARK: - Headings (Poppins)
        
        /// Size: 34, Weight: Bold
        static let largeTitle = Font.custom("Poppins-Bold", size: 34)
        
        /// Size: 28, Weight: Bold
        static let title = Font.custom("Poppins-Bold", size: 28)
        
        /// Size: 22, Weight: Bold
        static let title2 = Font.custom("Poppins-Bold", size: 22)
        
        /// Size: 20, Weight: Bold
        static let title3 = Font.custom("Poppins-Bold", size: 20)
        
        /// Size: 17, Weight: SemiBold
        static let headline = Font.custom("Poppins-SemiBold", size: 17)
        
        /// Size: 15, Weight: Medium
        static let subheadline = Font.custom("Poppins-Medium", size: 15)
        
        // MARK: - Body/Content (Inter)
        
        /// Size: 17, Weight: Regular
        static let body = Font.custom("Inter-Regular", size: 17)
        
        /// Size: 16, Weight: Regular
        static let callout = Font.custom("Inter-Regular", size: 16)
        
        /// Size: 13, Weight: Regular
        static let footnote = Font.custom("Inter-Regular", size: 13)
        
        /// Size: 12, Weight: Medium
        static let caption = Font.custom("Inter-Medium", size: 12)
        
        /// Size: 11, Weight: Medium
        static let caption2 = Font.custom("Inter-Medium", size: 11)
        
        // Specific
        static let logo = Font.custom("Righteous-Regular", size: 24)
    }
    
    // MARK: - Dimens / Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }
}
