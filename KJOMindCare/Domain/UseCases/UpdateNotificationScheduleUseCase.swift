//
//  UpdateNotificationScheduleUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

class UpdateNotificationScheduleUseCase {
    private let repo = UserProfileRepository()
    
    func execute(_ profile: UserProfile) async throws {
        try repo.saveProfile(profile)
    }
}
