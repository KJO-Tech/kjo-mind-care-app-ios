//
//  StorageService.swift
//  KJOMindCare
//
//  Created by DAMII on 20/12/25.
//

import Foundation

protocol StorageService {
    func upload(data: Data, folder: String, fileName: String?, resourceType: String?) async throws
        -> String
}
