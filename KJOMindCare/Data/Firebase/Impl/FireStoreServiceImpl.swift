//
//  FireStoreService.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//
import Foundation
import FirebaseFirestore

class FireStoreServiceImpl: FireStoreService  {
    
    private let db = Firestore.firestore()
    
    func save<T>(_ entity: T, at path: String) async throws where T : Encodable, T : Identifiable {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            do {
                guard let id = entity.id as? String else {
                    cont.resume(throwing: NSError(domain: "Firestore", code: -2, userInfo: [NSLocalizedDescriptionKey: "ID must be a String"]))
                    return
                }
                
                let ref = db.collection(path).document(id)
                
                try ref.setData(from: entity) { error in
                    if let error = error {
                        cont.resume(throwing: error)
                        return
                    }
                    cont.resume(returning: ())
                }
                
            } catch {
                cont.resume(throwing: error)
            }
        }
    }
    
    func get<T>(from path: String, id: String) async throws -> T? where T : Decodable, T : Encodable {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<T?, Error>) in
            let ref = db.collection(path).document(id)
            
            ref.getDocument { document, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }
                
                guard let document = document, document.exists else {
                    cont.resume(returning: nil)
                    return
                }
                
                do {
                    let value = try document.data(as: T.self)
                    cont.resume(returning: value)
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    func getCollection<T>(from path: String) async throws -> [T] where T : Decodable, T : Encodable {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[T], Error>) in
            
            db.collection(path).getDocuments { snapshot, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    cont.resume(returning: [])
                    return
                }
                
                do {
                    let values = try docs.map { try $0.data(as: T.self) }
                    cont.resume(returning: values)
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    func update(at path: String, id: String, with fields: [String : Any]) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            
            let ref = db.collection(path).document(id)
            
            ref.updateData(fields) { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }
    
    func delete(at path: String, id: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            
            let ref = db.collection(path).document(id)
            
            ref.delete { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }
    
    
}
