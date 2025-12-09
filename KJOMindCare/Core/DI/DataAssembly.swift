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
            AuthRepositoryImpl(
                authService: r.resolve(AuthFirebaseService.self)!,
                firestoreService: r.resolve(FireStoreService.self)!
            )
        }
        
        // Blog Repository
        container.register(BlogRepository.self) { r in
            BlogRepositoryImpl(
                firestoreService: r.resolve(FireStoreService.self)!
            )
        }
        
        // Category Repository
        container.register(CategoryRepository.self) { r in
            CategoryRepositoryImpl(
                firestoreService: r.resolve(FireStoreService.self)!
            )
        }
        
        // Daily Activity Repository
        container.register(DailyActivityRepository.self) { r in
            DailyActivityRepositoryImpl(
                firestoreService: r.resolve(FireStoreService.self)!
            )
        }
        
        // Activity Subscription Repository
        container.register(ActivitySubscriptionRepository.self) { r in
            ActivitySubscriptionRepositoryImpl(
                firestoreService: r.resolve(FireStoreService.self)!
            )
        }
        
        // Reaction Repository
        container.register(ReactionRepository.self) { r in
            ReactionRepositoryImpl(
                firestoreService: r.resolve(FireStoreService.self)!
            )
        }
        
        // Comment Repository
        container.register(CommentRepository.self) { r in
            CommentRepositoryImpl(
                firestoreService: r.resolve(FireStoreService.self)!
            )
        }
    }
}
