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
            Color.background.ignoresSafeArea()

            VStack(spacing: 20) {
                
                Spacer().frame(height: 10)

                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.primaryLight)
                            .frame(width: 100, height: 100)
                        Image("kjo_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            
                    }
                    Text("KJO Mind Care")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primaryDark)
                    Text("Bienestar mental a su alcance")
                        .font(.subheadline)
                        .foregroundColor(.primaryDark)
                    Spacer().frame(height: 30)
                    VStack(alignment: .leading, spacing: 25) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Bienvenidos de nuevo")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.primaryLight)
                            Text("Inicie sesión para continuar con su cuenta")
                                .font(.body)
                                .foregroundColor(.textSecondary)
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
                                //                                olvidar contra
                            }) {

                                Text("¿Olvidaste tu contraseña?")
                                    .font(.caption)
                                    .foregroundStyle(.primaryDark)
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
                            .foregroundColor(.textSecondary)
                        
                        Button(action:{
                            coordinator.showRegister()
                        }){
                            Text("Registrate")
                                .fontWeight(.bold)
                                .foregroundStyle(.primaryDark)
                        }
                        
                    }
                    .padding(.bottom,20)

                }
                .padding()
            }
        }
    }
}

#Preview {
    let loginVM = DIContainer.shared.container.resolve(LoginViewModel.self)!
    LoginView(viewModel: loginVM)
}
