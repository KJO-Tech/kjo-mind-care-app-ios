//
//  CloudinaryStorageServiceImpl.swift
//  KJOMindCare
//
//  Created by DAMII on 20/12/25.
//

import Cloudinary
import UIKit

class CloudinaryStorageServiceImpl: StorageService {
    private let cloudinary: CLDCloudinary
    private let uploadPreset = Configuration.cloudinaryUploadPreset

    init() {
        let config = CLDConfiguration(
            cloudName: Configuration.cloudinaryCloudName, secure: true)
        self.cloudinary = CLDCloudinary(configuration: config)
    }

    func upload(data: Data, folder: String, fileName: String?, resourceType: String? = nil)
        async throws
        -> String
    {
        return try await withCheckedThrowingContinuation { continuation in
            let params = CLDUploadRequestParams()
            params.setFolder(folder)

            // Set resource type for videos (default is "image")
            if let resourceType = resourceType {
                params.setResourceType(resourceType)
            }

            if let name = fileName {
                params.setPublicId(name)
                //                params.setOverwrite(true)
                //                params.setInvalidate(true)
            }

            let request = cloudinary.createUploader().upload(
                data: data, uploadPreset: uploadPreset, params: params
            )

            request.response { result, error in
                if let error = error {
                    print(
                        "❌ [Cloudinary] Error detallado: \(error.localizedDescription)"
                    )
                    continuation.resume(throwing: error)
                    return
                }

                if let url = result?.secureUrl {
                    // Force HTTPS if not present
                    let secureUrl = url.replacingOccurrences(of: "http://", with: "https://")
                    print("✅ [Cloudinary] Subida completa: \(secureUrl)")
                    continuation.resume(returning: secureUrl)
                } else {
                    continuation.resume(
                        throwing: NSError(domain: "Cloudinary", code: -1))
                }
            }
        }
    }
}
