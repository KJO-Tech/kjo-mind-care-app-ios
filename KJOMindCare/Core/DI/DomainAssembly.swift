//
//  DomainAssembly.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Swinject

final class DomainAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LoginUseCase.self){ r in
            LoginUseCase(
                repository: r.resolve(AuthRepository.self)!
            )
        }
        
        container.register(RegisterUseCase.self){ r in
            RegisterUseCase(
                repository: r.resolve(AuthRepository.self)!
            )
        }
    }
}
