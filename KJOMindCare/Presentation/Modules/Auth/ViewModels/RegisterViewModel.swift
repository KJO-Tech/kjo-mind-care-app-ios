//
//  RegisterViewModel.swift
//  KJOMindCare
//
//  Created by Raydberg on 20/11/25.
//

import Foundation

public class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var fullName: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var registeredUser: User?

    private let registerUseCase: RegisterUseCase

    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }

    var isFormValid: Bool {
        !email.isEmpty && !fullName.isEmpty && password.count >= 6 && password == confirmPassword
    }

    func register() async {
        guard isFormValid else {
            errorMessage = "Las contraseñas no coinciden o faltan datos."
            print("Registro fallido: formulario inválido")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await registerUseCase.execute(email: email, password: password, fullName: fullName)
            self.registeredUser = user
            errorMessage = nil
            print("Registro exitoso: \(user.fullName) (\(user.email))")
        } catch {
            self.errorMessage = "No se pudo registrar el usuario. \(error.localizedDescription)"
            self.registeredUser = nil
            print("Registro fallido: \(error.localizedDescription)")
        }
    }
}

