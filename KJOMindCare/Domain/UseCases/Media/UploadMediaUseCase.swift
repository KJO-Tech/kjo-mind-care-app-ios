//
//  UploadMediaUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 17/12/25.
//

import Foundation

class UploadMediaUseCase {
    private let mediaUploadRepository: MediaUploadRepository
    
    init(mediaUploadRepository: MediaUploadRepository) {
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func execute(data: Data, mediaType: MediaType) async throws -> String {
        return try await mediaUploadRepository.uploadMedia(data: data, mediaType: mediaType)
    }
}
