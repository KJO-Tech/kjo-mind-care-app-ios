import SwiftUI

struct DeleteConfirmationDialog: View {
    let title: String
    let message: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: "trash.fill")
                .font(.system(size: 50))
                .foregroundColor(Color.theme.error)

            // Title
            Text(title)
                .font(.title2.bold())
                .foregroundColor(Color.theme.text)

            // Message
            Text(message)
                .font(.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)

            // Buttons
            HStack(spacing: 12) {
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(Color.theme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.theme.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.theme.textSecondary.opacity(0.3), lineWidth: 1)
                        )
                }

                Button {
                    onDelete()
                } label: {
                    Text("Delete")
                        .font(.headline)
                        .foregroundColor(Color.theme.errorContent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.theme.error)
                        )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.shadow.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .edgesIgnoringSafeArea(.all)

        DeleteConfirmationDialog(
            title: "Delete Comment",
            message: "Are you sure you want to delete this comment? This action cannot be undone.",
            onDelete: {},
            onCancel: {}
        )
        .padding(.horizontal, 40)
    }
    .preferredColorScheme(.dark)
}
