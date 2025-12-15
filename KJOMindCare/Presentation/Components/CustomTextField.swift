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
            Text(LocalizedStringKey(title))
                .font(.theme.title3)
                .foregroundStyle(Color.theme.primary.opacity(0.8))
                .fontWeight(.medium)

            ZStack(alignment: .trailing) {
                if isSecure && !showPassword {
                    SecureField(LocalizedStringKey(placeholder), text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundStyle(Color.theme.text)
                } else {
                    TextField(LocalizedStringKey(placeholder), text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundStyle(Color.theme.text)
                        .autocapitalization(.none)
                }
                if isSecure {
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .foregroundStyle(Color.theme.primary.opacity(0.8))
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.theme.primary, lineWidth: 1)
            )

        }
    }
}

#Preview {
    @Previewable @State var previewText = ""
    CustomTextField(
        title: "Login", placeholder: "placeholder", text: $previewText)
}
