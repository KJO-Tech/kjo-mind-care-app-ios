//
//  StorageError.swift
//  KJOMindCare
//
//  Created by DAMII on 20/12/25.
//

enum StorageError: Error {
    case imageConversionFailed
    case uploadFailed(String)
    case unknown
}
