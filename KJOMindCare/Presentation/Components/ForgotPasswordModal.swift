//
//  ForgotPasswordModal.swift
//  KJOMindCare
//
//  Created by DAMII on 3/12/25.
//

import SwiftUI

struct ForgotPasswordModal: View {
    @Binding var isActive: Bool
    @Binding var email: String
    var onSend: () -> Void

    var body: some View {
        ZStack {
            Color.theme.shadow.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isActive = false
                    }
                }

            VStack(spacing: 20) {
                Text("Recuperar Contraseña")
                    .font(.theme.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.text)

                Text(
                    "Ingresa tu correo electronico asociado a tu cuenta"
                )
                .font(.theme.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.theme.textSecondary)
                .padding(.horizontal)

                TextField(
                    "Tu correo",
                    text: $email

                )
                .foregroundStyle(Color.theme.text)
                .padding()
                .background(Color.theme.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.theme.primary, lineWidth: 1)
                )
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

                HStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            isActive = false
                        }
                    }) {
                        Text("Cancelar")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.background)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        onSend()
                    }) {
                        Text("Enviar")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.theme.primaryContent)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.primary)
                            .cornerRadius(10)
                    }
                    .disabled(email.isEmpty)
                    .opacity(email.isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 25)
            .background(Color.theme.card)
            .cornerRadius(20)
            .shadow(color: Color.theme.shadow.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(30)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var isActive = true
        @State var email = ""

        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()

                if !isActive {
                    Button("Abrir Modal") {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
                if isActive {
                    ForgotPasswordModal(
                        isActive: $isActive,
                        email: $email,
                        onSend: {
                            print("Botón enviar presionado. Email: \(email)")
                            withAnimation {
                                isActive = false
                            }
                        }
                    )
                }
            }
        }
    }

    return PreviewWrapper()
}
