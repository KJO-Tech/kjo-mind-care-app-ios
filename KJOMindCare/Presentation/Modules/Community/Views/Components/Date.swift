import Foundation

extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full   
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
