//
//  ActivityCategory.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

struct ActivityCategory: Codable, Identifiable {
    var id: String
    var localizedName: [String: String]
    var localizedDescription: [String: String]
    var iconResName: String
    var imageUrl: String
    var order: Int
    
    init(
        id: String = "",
        localizedName: [String: String] = [:],
        localizedDescription: [String: String] = [:],
        iconResName: String = "",
        imageUrl: String = "",
        order: Int = 0
    ) {
        self.id = id
        self.localizedName = localizedName
        self.localizedDescription = localizedDescription
        self.iconResName = iconResName
        self.imageUrl = imageUrl
        self.order = order
    }
    
    func getName(languageCode: String? = nil) -> String {
        let code = languageCode ?? getCurrentLanguageCode()
        return localizedName[code] ??
               localizedName["en"] ??
               localizedName.values.first ??
               "Unnamed Category"
    }
    
    func getDescription(languageCode: String? = nil) -> String {
        let code = languageCode ?? getCurrentLanguageCode()
        return localizedDescription[code] ??
               localizedDescription["en"] ??
               localizedDescription.values.first ??
               ""
    }
    
    private func getCurrentLanguageCode() -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode.starts(with: "es") ? "es" : "en"
    }
}
