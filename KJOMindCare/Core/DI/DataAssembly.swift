//
//  DataAssembly.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Swinject

final class DataAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthFirebaseService.self) { _ in
            AutAuthFirebaseServiceImpl()
        }.inObjectScope(.container)
        
        container.register(FireStoreService.self){ _ in
            FireStoreServiceImpl()
        }.inObjectScope(.container)
        
        container.register(AuthRepository.self){ r in
            
            AuthRepositoryImpl(authService: r.resolve(AuthFirebaseService.self)!, firestoreService: r.resolve(FireStoreService.self)!)
            
        }
    }
}
