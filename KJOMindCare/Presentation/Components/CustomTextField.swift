//
//  CustomTextField.swift
//  KJOMindCare
//
//  Created by DAMII on 19/11/25.
//

import SwiftUI

struct CustomTextField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var showPassword: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .foregroundStyle(.primaryDark)
                .fontWeight(.medium)
                

            ZStack(alignment: .trailing) {
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundStyle(.white)
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundStyle(.white)
                        .autocapitalization(.none)
                }
                if isSecure {
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .foregroundStyle(Color.primaryDark)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryLight, lineWidth: 1)
            )

        }
    }
}

#Preview {
    @Previewable @State var previewText = ""
    CustomTextField(
        title: "Login", placeholder: "placeholder", text: $previewText)
}
