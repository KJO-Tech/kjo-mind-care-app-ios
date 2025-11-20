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
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryLight)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

#Preview {
    PrimaryButton(title: "Login") {}
}
