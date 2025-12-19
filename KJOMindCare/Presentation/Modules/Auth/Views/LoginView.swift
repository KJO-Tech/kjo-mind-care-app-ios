//
//  LoginView.swift
//  KJOMindCare
//
//  Created by Raydberg on 19/11/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel

    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            ScrollView {

                VStack(spacing: 20) {

                    Spacer().frame(height: 10)

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
                        Text("auth.login.slogan")
                            .font(.theme.subheadline)
                            .foregroundColor(Color.theme.text)
                        Spacer().frame(height: 30)
                        VStack(alignment: .leading, spacing: 25) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("auth.login.welcomeTitle")
                                    .font(.theme.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.theme.primary.opacity(0.8))
                                Text("auth.login.welcomeSubtitle")
                                    .font(.theme.subheadline)
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            CustomTextField(
                                title: "auth.login.email.title",
                                placeholder: "auth.login.email.placeholder",
                                text: $viewModel.email
                            )
                            .keyboardType(.emailAddress)

                            VStack(alignment: .trailing) {
                                CustomTextField(
                                    title: "auth.login.password.title",
                                    placeholder: "auth.login.password.placeholder",
                                    text: $viewModel.password,
                                    isSecure: true
                                )

                                Button(action: {
                                    withAnimation {
                                        viewModel.recoveryEmail = viewModel.email
                                        viewModel.showForgotPasswordModal = true
                                    }
                                }) {

                                    Text("auth.login.forgotPassword")
                                        .font(.theme.caption)
                                        .foregroundStyle(Color.theme.primary)
                                        .padding(.top, 5)
                                }

                            }

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            PrimaryButton(
                                title: viewModel.isLoading
                                    ? "auth.login.loading" : "auth.login.signInButton"
                            ) {
                                Task {
                                    viewModel.errorMessage = nil
                                    viewModel.isLoading = true
                                    defer { viewModel.isLoading = false }

                                    await viewModel.login()

                                    if viewModel.loggedUser != nil {
                                        withAnimation {
                                            coordinator.showMain()
                                        }
                                    }
                                }

                            }.disabled(!viewModel.isFormValid || viewModel.isLoading)
                                .opacity(viewModel.isFormValid ? 1.0 : 0.6)

                            HStack {
                                Rectangle()
                                    .fill(Color.theme.divider.opacity(0.3))
                                    .frame(height: 1)
                                Text("auth.login.orSeparator")
                                    .font(.theme.caption)
                                    .foregroundColor(Color.theme.textSecondary)
                                Rectangle()
                                    .fill(Color.theme.divider.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 3)

                            Button(action: {
                                Task {
                                    await viewModel.signInWithGoogle()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image("google")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    Text("auth.login.googleSignIn")
                                        .font(.theme.headline)
                                        .foregroundStyle(Color.theme.text)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme.background)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.surface, lineWidth: 2)
                                )
                                .cornerRadius(12)
                                .shadow(
                                    color: Color.theme.shadow.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .disabled(viewModel.isLoading)

                        }
                        .padding(.horizontal)
                        Spacer().frame(height: 10)

                        HStack {
                            Text("auth.login.noAccount")
                                .foregroundColor(Color.theme.textSecondary)

                            Button(action: {
                                coordinator.showRegister()
                            }) {
                                Text("auth.login.register")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.theme.primary)
                            }

                        }
                        .padding(.bottom, 20)

                    }
                    .padding()
                }

                .blur(radius: viewModel.showForgotPasswordModal ? 3 : 0)
                .disabled(viewModel.showForgotPasswordModal)

                if viewModel.showForgotPasswordModal {
                    ForgotPasswordModal(
                        isActive: $viewModel.showForgotPasswordModal,
                        email: $viewModel.recoveryEmail,
                        onSend: {
                            Task {
                                await viewModel.sendPasswordReset()
                            }
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    let loginVM = DIContainer.shared.container.resolve(LoginViewModel.self)!
    let coordinator = AppCoordinator()
    LoginView(viewModel: loginVM)
        .environmentObject(coordinator)
}
