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

    public init() {}

    var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }

    func login() async {

        guard isFormValid else {
            errorMessage = "Error al logearse"
            return
        }

        isLoading = true

        defer { isLoading = false }

        print("Login con email \(email) y password \(password)")
    }

}
