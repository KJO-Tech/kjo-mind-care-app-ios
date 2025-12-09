//
//  PrimaryButton.swift
//  KJOMindCare
//
//  Created by DAMII on 19/11/25.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.theme.headline)
                .foregroundStyle(Color.theme.primaryContent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.primary)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

#Preview {
    PrimaryButton(title: "Login") {}
}
