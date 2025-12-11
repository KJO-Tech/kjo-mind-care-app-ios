import SwiftUI

struct DeleteConfirmationDialog: View {
    let title: String
    let message: String
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 24)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 16) {
                        Button {
                            onCancel()
                        } label: {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        
                        Button {
                            onDelete()
                        } label: {
                            Text("Delete")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.red)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(white: 0.15))
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                )
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    DeleteConfirmationDialog(
        title: "Delete Comment",
        message: "Are you sure you want to delete this comment? This action cannot be undone.",
        onDelete: {},
        onCancel: {}
    )
    .preferredColorScheme(.dark)
}
