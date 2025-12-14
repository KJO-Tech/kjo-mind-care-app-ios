//
//  RegisterView.swift
//  KJOMindCare
//
//  Created by Raydberg on 19/11/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel

    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.theme.primary)
                                .frame(width: 100, height: 100)
                            Image("kjo_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }

                        Text("auth.login.appName")
                            .font(.theme.logo)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.theme.primary)

                    }

                    VStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("auth.register.title")
                                .font(.theme.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.theme.primary.opacity(0.8))
                            Text("auth.register.subtitle")
                                .font(.theme.subheadline)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        CustomTextField(
                            title: "auth.register.fullName.title",
                            placeholder: "auth.register.fullName.placeholder",
                            text: $viewModel.fullName
                        )

                        CustomTextField(
                            title: "auth.register.email.title",
                            placeholder: "auth.register.email.placeholder",
                            text: $viewModel.email
                        )
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)

                        CustomTextField(
                            title: "auth.register.password.title",
                            placeholder: "auth.register.password.placeholder",
                            text: $viewModel.password,
                            isSecure: true
                        )

                        CustomTextField(
                            title: "auth.register.confirmPassword.title",
                            placeholder: "auth.register.confirmPassword.placeholder",
                            text: $viewModel.confirmPassword,
                            isSecure: true
                        )

                        if !viewModel.confirmPassword.isEmpty
                            && viewModel.password != viewModel.confirmPassword
                        {
                            Text("auth.register.passwordMismatch")
                                .font(.theme.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

                        PrimaryButton(
                            title: viewModel.isLoading
                                ? "auth.register.loading" : "auth.register.signUpButton"
                        ) {
                            Task {

                                viewModel.errorMessage = nil

                                await viewModel.register()

                                if let user = viewModel.registeredUser {
                                    print(
                                        "Usuario registrado correctamente: \(user.fullName) (\(user.email))"
                                    )
                                    withAnimation {
                                        coordinator.showSubscription()
                                    }
                                } else if let error = viewModel.errorMessage {
                                    print("Error al registrar usuario: \(error)")
                                }
                            }
                        }
                        .padding(.top, 8)
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 15) {

                        HStack(spacing: 5) {
                            Text("auth.register.haveAccount")
                                .foregroundColor(Color.theme.textSecondary)

                            Button(action: {
                                coordinator.pop()
                            }) {
                                Text("auth.register.login")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.theme.primary)
                            }
                        }
                        .font(.theme.subheadline)
                        Spacer().frame(height: 1)
                    }
                    .padding(.bottom, 10)

                }
                .padding()
            }

        }

        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
            for: nil)
    }
}

#Preview {
    let registerVM = DIContainer.shared.container.resolve(
        RegisterViewModel.self)!
    RegisterView(viewModel: registerVM)
}
