//
//  LoginViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 19/11/25.
//

import Foundation

public class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var loggedUser: User?

    private let loginUseCase: LoginUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase

    init(loginUseCase: LoginUseCase, getCurrentUserUseCase: GetCurrentUserUseCase) {
        self.loginUseCase = loginUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.loggedUser = getCurrentUserUseCase.execute()
    }

    var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }

    func login() async {
        guard isFormValid else {
            errorMessage = "Formulario inválido"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await loginUseCase.execute(email: email, password: password)
            self.loggedUser = user
            print("Usuario \(user.fullName) (\(user.email)) inició sesión correctamente")
        } catch {
            self.errorMessage = "Email o contraseña incorrectos"
            self.loggedUser = nil
            print("Login fallido para email \(email): \(error.localizedDescription)")
        }
    }
}
