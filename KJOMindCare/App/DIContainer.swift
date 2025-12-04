//
//  DIContainer.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Swinject

final class DIContainer {
    static let shared = DIContainer()
    
    let container: Container
    
    init() {
        let cont = Container()
        
        AppAssembly().assemble(container: cont)
        DataAssembly().assemble(container: cont)
        DomainAssembly().assemble(container: cont)
        PresentationAssembly().assemble(container: cont)
        
        self.container = cont
    }
}
