import Foundation

public struct Mood: Codable, Identifiable, Equatable {
    public let id: String
    public let name: [String: String]
    public let description: [String: String]
    public let image: String
    public let color: String
    public let isActive: Bool
    public let value: Int

    public init(
        id: String, name: [String: String], description: [String: String], image: String,
        color: String, isActive: Bool, value: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.color = color
        self.isActive = isActive
        self.value = value
    }

    public func getName(languageCode: String? = nil) -> String {
        let code = languageCode ?? Locale.current.language.languageCode?.identifier ?? "en"
        return name[code] ?? name["en"] ?? name.values.first ?? "Unnamed Mood"
    }

    public func getDescription(languageCode: String? = nil) -> String {
        let code = languageCode ?? Locale.current.language.languageCode?.identifier ?? "en"
        return description[code] ?? description["en"] ?? description.values.first ?? ""
    }
}
