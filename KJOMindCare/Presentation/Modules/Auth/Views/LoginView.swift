//
//  LoginView.swift
//  KJOMindCare
//
//  Created by DAMII on 19/11/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
   

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

                        PrimaryButton(title: "Iniciar sesión") {
                            viewModel.login()
                        }

                    }
                    .padding(.horizontal)
                    Spacer()

                    HStack {
                        Text("¿No tienes una cuenta?")
                            .foregroundColor(.textSecondary)
                        
                        Button(action:{
//                            Navegadar a registro
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
    LoginView()
}
