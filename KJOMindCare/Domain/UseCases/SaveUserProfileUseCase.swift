//
//  SaveUserProfileUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

import UIKit

class SaveUserRemoteUseCase {
    private let storageService: StorageService
    private let firestoreService: FireStoreService

    init(storageService: StorageService, firestoreService: FireStoreService) {
        self.storageService = storageService
        self.firestoreService = firestoreService
    }

    func execute(user: User, image: UIImage?) async throws -> User {
        var updatedUser = user

        if let image = image {
            guard let data = image.jpegData(compressionQuality: 0.7) else {
                throw StorageError.imageConversionFailed
            }

            let timestamp = Int(Date().timeIntervalSince1970)
            let uniqueFileName = "profile_\(user.uid)_\(timestamp)"

            let photoURL = try await storageService.upload(
                data: data,
                folder: "users/profiles",
                fileName: uniqueFileName,
                resourceType: nil
            )

            updatedUser.profileImage = photoURL
        }

        let dataToUpdate: [String: Any] = [
            "fullName": updatedUser.fullName,
            "profileImage": updatedUser.profileImage ?? "",
        ]

        try await firestoreService.update(
            at: "users", id: user.uid, with: dataToUpdate)

        return updatedUser
    }
}
