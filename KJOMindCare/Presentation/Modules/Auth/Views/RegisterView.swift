//
//  RegisterView.swift
//  KJOMindCare
//
//  Created by Raydberg on 19/11/25.
//


import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
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
                    
                }
                
                VStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Crear una cuenta")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primaryLight)
                        Text("Únase a nuestra comunidad de bienestar mental")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
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
                    
                    
                    if !viewModel.confirmPassword.isEmpty && viewModel.password != viewModel.confirmPassword {
                        Text("Las contraseñas no coinciden")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                   
                    PrimaryButton(title: viewModel.isLoading ? "Cargando..." : "Registrarse") {
                        Task {
                            await viewModel.register()
                        }
                    }
                    .padding(.top, 8)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                }
                .padding(.horizontal)
                
                Spacer()
                
                
                VStack(spacing: 15) {
                   
                    HStack(spacing: 5) {
                        Text("¿Ya tienes una cuenta?")
                            .foregroundColor(.textSecondary)
                        
                        Button(action: {
                            // Navegar a login
                        }) {
                            Text("Inicia Sesión")
                                .fontWeight(.bold)
                                .foregroundStyle(.primaryDark)
                        }
                    }
                    .font(.subheadline)
                    

                }
                .padding(.bottom, 10)
            }
            .padding()
        }
     
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    RegisterView()
}
