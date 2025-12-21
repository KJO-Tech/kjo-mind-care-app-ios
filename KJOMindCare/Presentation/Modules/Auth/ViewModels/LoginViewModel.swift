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
    @Published var showForgotPasswordModal: Bool = false
    @Published var recoveryEmail: String = ""

    private let loginUseCase: LoginUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let loginWithGoogleUseCase: LoginWithGoogleUseCase

    init(loginUseCase: LoginUseCase, getCurrentUserUseCase: GetCurrentUserUseCase, loginWithGoogleUseCase: LoginWithGoogleUseCase) {
        self.loginUseCase = loginUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.loginWithGoogleUseCase = loginWithGoogleUseCase
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
            let user = try await loginUseCase.execute(
                email: email, password: password)
            self.loggedUser = user
            print(
                "Usuario \(user.fullName) (\(user.email)) inició sesión correctamente"
            )
        } catch {
            self.errorMessage = "Email o contraseña incorrectos"
            self.loggedUser = nil
            print(
                "Login fallido para email \(email): \(error.localizedDescription)"
            )
        }
    }
    func sendPasswordReset() async {
        isLoading = true
        defer {
            isLoading = false
        }

        print("Enviar correo de recuperacion a ; \(recoveryEmail)")
        await MainActor.run {
            self.showForgotPasswordModal = false
            self.recoveryEmail = ""
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await loginWithGoogleUseCase.execute()
            self.loggedUser = user
            print("Usuario \(user.fullName) (\(user.email)) inició sesión con Google correctamente")
        } catch {
            self.errorMessage = "Error al iniciar sesión con Google"
            self.loggedUser = nil
            print("Google Sign-In fallido: \(error.localizedDescription)")
        }
    }

}
