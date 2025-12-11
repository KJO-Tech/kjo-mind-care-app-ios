//
//  DailyExercise.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import FirebaseFirestore
import Foundation

enum ExerciseDifficultyType: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct DailyExercise: Codable, Identifiable {
    @DocumentID var id: String?
    var categoryId: String
    var localizedTitle: [String: String?]
    var localizedDescription: [String: String?]
    var durationMinutes: Int
    var contentType: ExerciseContentType
    var contentUrl: String
    var localizedContentText: [String: String?]
    var thumbnailUrl: String?
    var difficulty: ExerciseDifficultyType
    var tags: [String]

    init(
        id: String? = nil,
        categoryId: String = "",
        localizedTitle: [String: String?] = [:],
        localizedDescription: [String: String?] = [:],
        durationMinutes: Int = 0,
        contentType: ExerciseContentType = .TEXT,
        contentUrl: String = "",
        localizedContentText: [String: String?] = [:],
        thumbnailUrl: String? = nil,
        difficulty: ExerciseDifficultyType = .beginner,
        tags: [String] = []
    ) {
        self.id = id
        self.categoryId = categoryId
        self.localizedTitle = localizedTitle
        self.localizedDescription = localizedDescription
        self.durationMinutes = durationMinutes
        self.contentType = contentType
        self.contentUrl = contentUrl
        self.localizedContentText = localizedContentText
        self.thumbnailUrl = thumbnailUrl
        self.difficulty = difficulty
        self.tags = tags
    }

    func getTitle(languageCode: String? = nil) -> String {
        let code = languageCode ?? getCurrentLanguageCode()
        return
            ((localizedTitle[code] ?? localizedTitle["en"] ?? localizedTitle.values.first)
            ?? "Untitled Exercise")!
    }

    func getDescription(languageCode: String? = nil) -> String {
        let code = languageCode ?? getCurrentLanguageCode()
        return
            ((localizedDescription[code] ?? localizedDescription["en"]
            ?? localizedDescription.values.first)
            ?? "")!
    }

    func getContentText(languageCode: String? = nil) -> String {
        let code = languageCode ?? getCurrentLanguageCode()
        return
            ((localizedContentText[code] ?? localizedContentText["en"]
            ?? localizedContentText.values.first)
            ?? "")!
    }

    private func getCurrentLanguageCode() -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode.starts(with: "es") ? "es" : "en"
    }
}
