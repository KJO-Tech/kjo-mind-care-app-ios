//
//  MediaUploadRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 17/12/25.
//

import Foundation

protocol MediaUploadRepository {
    func uploadMedia(data: Data, mediaType: MediaType) async throws -> String
}
