//
//  LoginView.swift
//  KJOMindCare
//
//  Created by Raydberg on 19/11/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel:LoginViewModel
    
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
                        Text("KJO Mind Care")
                            .font(.theme.logo)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.theme.primary)
                        Text("Bienestar mental a su alcance")
                            .font(.theme.subheadline)
                            .foregroundColor(Color.theme.text)
                        Spacer().frame(height: 30)
                        VStack(alignment: .leading, spacing: 25) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Bienvenidos de nuevo")
                                    .font(.theme.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.theme.primary.opacity(0.8))
                                Text("Inicie sesión para continuar con su cuenta")
                                    .font(.theme.subheadline)
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            CustomTextField(
                                title: "Email",
                                placeholder: "Ingrese su correo",
                                text: $viewModel.email
                            )
                            .keyboardType(.emailAddress)
                            
                            VStack(alignment: .trailing) {
                                CustomTextField(
                                    title: "Contraseña",
                                    placeholder: "Ingrese su contraseña",
                                    text: $viewModel.password,
                                    isSecure: true
                                )
                                
                                Button(action: {
                                    withAnimation{
                                        viewModel.recoveryEmail = viewModel.email
                                        viewModel.showForgotPasswordModal = true
                                    }
                                }) {
                                    
                                    Text("¿Olvidaste tu contraseña?")
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
                            
                            PrimaryButton(title: viewModel.isLoading ? "Cargando...": "Iniciar Sesion") {
                                Task{
                                    viewModel.errorMessage = nil
                                    viewModel.isLoading = true
                                    defer { viewModel.isLoading = false }
                                    
                                    await viewModel.login()
                                    
                                    if let _ = viewModel.loggedUser {
                                        withAnimation{
                                            coordinator.showMain()
                                        }
                                    }
                                }
                                
                            }.disabled(!viewModel.isFormValid || viewModel.isLoading)
                                .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                            
                        }
                        .padding(.horizontal)
                        Spacer().frame(height: 10)
                        
                        HStack {
                            Text("¿No tienes una cuenta?")
                                .foregroundColor(Color.theme.textSecondary)
                            
                            Button(action:{
                                coordinator.showRegister()
                            }){
                                Text("Registrate")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.theme.primary)
                            }
                            
                        }
                        .padding(.bottom,20)
                        
                    }
                    .padding()
                }
                
                .blur(radius: viewModel.showForgotPasswordModal ? 3 : 0)
                .disabled(viewModel.showForgotPasswordModal)
                
                if viewModel.showForgotPasswordModal {
                    ForgotPasswordModal(
                        isActive: $viewModel.showForgotPasswordModal, email: $viewModel.recoveryEmail, onSend: {
                            Task{
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
