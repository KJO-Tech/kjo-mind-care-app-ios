//
//  MediaUploadRepositoryImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 17/12/25.
//

import Foundation
import Cloudinary

class MediaUploadRepositoryImpl: MediaUploadRepository {
    private let cloudinary: CLDCloudinary
    
    init() {
        // Initialize Cloudinary with configuration
        // You'll need to add these values to your Info.plist or configuration
        let config = CLDConfiguration(
            cloudName: Bundle.main.object(forInfoDictionaryKey: "CLOUDINARY_CLOUD_NAME") as? String ?? "",
            apiKey: Bundle.main.object(forInfoDictionaryKey: "CLOUDINARY_API_KEY") as? String ?? "",
            apiSecret: Bundle.main.object(forInfoDictionaryKey: "CLOUDINARY_API_SECRET") as? String ?? ""
        )
        self.cloudinary = CLDCloudinary(configuration: config)
    }
    
    func uploadMedia(data: Data, mediaType: MediaType) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            // Determine the folder based on media type
            let folder = mediaType == .IMAGE ? "blog/images" : "blog/videos"
            
            // Determine resource type
            let resourceType = mediaType == .IMAGE ? "image" : "video"
            
            // Create upload parameters
            let params = CLDUploadRequestParams()
            params.setFolder(folder)
            params.setResourceType(resourceType)
            
            // Perform upload
            let request = cloudinary.createUploader().upload(
                data: data,
                uploadPreset: nil,
                params: params,
                progress: nil
            ) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result,
                      let url = result.url else {
                    continuation.resume(throwing: MediaUploadError.urlExtractionFailed)
                    return
                }
                
                continuation.resume(returning: url)
            }
            
            // Optional: You can track the request if needed
            _ = request
        }
    }
}

// Custom error for media upload
enum MediaUploadError: LocalizedError {
    case urlExtractionFailed
    case invalidConfiguration
    
    var errorDescription: String? {
        switch self {
        case .urlExtractionFailed:
            return "Failed to extract URL from upload result"
        case .invalidConfiguration:
            return "Cloudinary configuration is invalid"
        }
    }
}
