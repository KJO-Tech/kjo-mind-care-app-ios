//
//  PresentationAssembly.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Swinject

final class PresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LoginViewModel.self) { r in
            LoginViewModel(loginUseCase: r.resolve(LoginUseCase.self)!)
        }

        container.register(RegisterViewModel.self) { r in
            RegisterViewModel(registerUseCase: r.resolve(RegisterUseCase.self)!)
        }

        container.register(SplashViewModel.self) { r in
            SplashViewModel(checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!)
        }

        container.register(HomeViewModel.self) { r in
            HomeViewModel(
                getMoodsUseCase: r.resolve(GetMoodsUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                getUserProfileUseCase: r.resolve(GetUserProfileUseCase.self)!
            )
        }

        container.register(RecordMoodViewModel.self) { r in
            RecordMoodViewModel(getMoodsUseCase: r.resolve(GetMoodsUseCase.self)!)
        }

    }
}
