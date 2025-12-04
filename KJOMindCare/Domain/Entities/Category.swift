//
//  Category.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

struct Category: Codable, Identifiable {
    var id: String
    var nameTranslations: [String: String]
    var isActive: Bool
    
    init(
        id: String = "",
        nameTranslations: [String: String] = [:],
        isActive: Bool = true
    ) {
        self.id = id
        self.nameTranslations = nameTranslations
        self.isActive = isActive
    }
    
    func getLocalizedName(languageCode: String) -> String {
        return nameTranslations[languageCode] ??
               nameTranslations["en"] ??
               nameTranslations.values.first ??
               "Unnamed Category"
    }
}
