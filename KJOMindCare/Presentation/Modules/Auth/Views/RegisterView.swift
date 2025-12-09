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
                        
                        Text("KJO Mind Care")
                            .font(.theme.logo)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.theme.primary)
                        
                    }
                    
                    VStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Crear una cuenta")
                                .font(.theme.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.theme.primary.opacity(0.8))
                            Text("Regístrese para comenzar")
                                .font(.theme.subheadline)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CustomTextField(
                            title: "Nombre Completo",
                            placeholder: "Ingrese su nombre completo",
                            text: $viewModel.fullName
                        )
                        
                        CustomTextField(
                            title: "Email",
                            placeholder: "Ingrese su correo",
                            text: $viewModel.email
                        )
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        
                        CustomTextField(
                            title: "Contraseña",
                            placeholder: "Ingrese su contraseña",
                            text: $viewModel.password,
                            isSecure: true
                        )
                        
                        CustomTextField(
                            title: "Confirmar Contraseña",
                            placeholder: "Repita su contraseña",
                            text: $viewModel.confirmPassword,
                            isSecure: true
                        )
                        
                        if !viewModel.confirmPassword.isEmpty
                            && viewModel.password != viewModel.confirmPassword
                        {
                            Text("Las contraseñas no coinciden")
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
                            ? "Cargando..." : "Registrarse"
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
                            Text("¿Ya tienes una cuenta?")
                                .foregroundColor(Color.theme.textSecondary)
                            
                            Button(action: {
                                coordinator.pop()
                            }) {
                                Text("Inicia Sesión")
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
