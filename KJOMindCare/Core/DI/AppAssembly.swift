//
//  AppAssembly.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//
import Swinject

final class AppAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FirebaseConfig.self) { _ in
            FirebaseConfig()
        }.inObjectScope(.container)
    }
}
