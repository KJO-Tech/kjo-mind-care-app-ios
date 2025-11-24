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

    public init() {}

    var isFormValid: Bool {
        !email.isEmpty && !fullName.isEmpty && password.count >= 6 && password == confirmPassword
    }

    func register() async {
        guard isFormValid else {
            errorMessage = "Las contraseñas no coinciden o faltan datos."
            return
        }

        isLoading = true
        defer { isLoading = false }

        print("Registrando a \(fullName)")
    }

}
