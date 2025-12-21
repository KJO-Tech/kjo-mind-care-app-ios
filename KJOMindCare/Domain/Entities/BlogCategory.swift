import Foundation

public enum BlogCategory: String, CaseIterable, Identifiable, Codable {
    case sleep = "sleep"
    case anxiety = "anxiety"
    case stress = "stress"
    case other = "other"
    case meditation = "meditation"
    case nutrition = "nutrition"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .sleep:
            return "Sleep"
        case .anxiety:
            return "Anxiety"
        case .stress:
            return "Stress"
        case .other:
            return "Other"
        case .meditation:
            return "Meditation"
        case .nutrition:
            return "Nutrition"
        }
    }
    
    public var icon: String {
        switch self {
        case .sleep:
            return "moon.stars.fill"
        case .anxiety:
            return "heart.fill"
        case .stress:
            return "bolt.fill"
        case .other:
            return "ellipsis.circle.fill"
        case .meditation:
            return "figure.mind.and.body"
        case .nutrition:
            return "leaf.fill"
        }
    }
}
