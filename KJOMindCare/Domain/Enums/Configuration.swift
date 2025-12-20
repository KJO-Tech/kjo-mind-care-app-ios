//
//  Configuration.swift
//  KJOMindCare
//
//  Created by DAMII on 20/12/25.
//

import Foundation

enum Configuration {
    static var cloudinaryCloudName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CloudinaryCloudName")
            as? String ?? ""
    }

    static var cloudinaryUploadPreset: String {
        return Bundle.main.object(
            forInfoDictionaryKey: "CloudinaryUploadPreset") as? String ?? ""
    }
}
