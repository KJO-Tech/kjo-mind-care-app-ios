//
//  StorageService.swift
//  KJOMindCare
//
//  Created by DAMII on 20/12/25.
//

import UIKit

protocol StorageService {
    func upload(data: Data, folder: String, fileName: String?) async throws -> String
}
