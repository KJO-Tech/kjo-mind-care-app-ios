//
//  FireStoreService.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Foundation
import FirebaseFirestore

protocol FireStoreService {
    func save<T: Encodable & Identifiable>(_ entity: T, at path: String) async throws
    func get<T: Codable>(from path: String, id:String) async throws -> T?
    func getCollection<T: Codable>(from path: String) async throws -> [T]
    func update(at path:String , id: String, with fields: [String: Any]) async throws
    func delete(at path:String , id: String) async throws
}
