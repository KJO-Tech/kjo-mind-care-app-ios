//
//  UpdateNotificationScheduleUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

class UpdateUserSettingsUseCase {
    private let repo: UserSettingsRepository
    
    init(repo: UserSettingsRepository) {
        self.repo = repo
    }
    
    func execute(_ settings: UserSettings) async throws {
        try await repo.saveSettings(settings)
    }
}
