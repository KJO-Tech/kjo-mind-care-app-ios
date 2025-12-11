import FirebaseFirestore
import Foundation

struct ActivityCategory: Codable, Identifiable {
    @DocumentID var id: String?
    var localizedName: [String: String?]
    var localizedDescription: [String: String?]
    var imageUrl: String
    var order: Int

    init(
        id: String? = nil,
        localizedName: [String: String?] = [:],
        localizedDescription: [String: String?] = [:],
        imageUrl: String = "",
        order: Int = 0
    ) {
        self.id = id
        self.localizedName = localizedName
        self.localizedDescription = localizedDescription
        self.imageUrl = imageUrl
        self.order = order
    }

    func getName(languageCode: String? = nil) -> String {
        let code = languageCode ?? getCurrentLanguageCode()
        return ((localizedName[code] ?? localizedName["en"] ?? localizedName.values.first) ?? "Unnamed Category") ?? ""
    }

    func getDescription(languageCode: String? = nil) -> String {
        let code = languageCode ?? getCurrentLanguageCode()
        return ((localizedDescription[code] ?? localizedDescription["en"]
          ?? localizedDescription.values.first)
         ?? "Unnamed") ?? ""
    }

    private func getCurrentLanguageCode() -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode.starts(with: "es") ? "es" : "en"
    }
}
