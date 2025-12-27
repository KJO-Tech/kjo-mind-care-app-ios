import Foundation

enum SubscriptionType: String, CaseIterable, Identifiable, Codable {
    case breathing
    case meditation
    case movement
    case journal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breathing:
            return "Breathing Exercise"
        case .meditation:
            return "Meditation"
        case .movement:
            return "Movement & Stretch"
        case .journal:
            return "Journal Exercise"
        }
    }

    var icon: String {
        switch self {
        case .breathing:
            return "lungs.fill"
        case .meditation:
            return "figure.mind.and.body"
        case .movement:
            return "figure.run"
        case .journal:
            return "pencil"
        }
    }
}

