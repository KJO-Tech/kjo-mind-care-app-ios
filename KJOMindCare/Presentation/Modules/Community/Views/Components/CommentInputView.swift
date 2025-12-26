import SwiftUI

struct CommentInputView: View {
    let mode: CommentMode
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void

    private var placeholder: String {
        switch mode {
        case .create:
            return "Write your comment..."
        case .edit:
            return "Edit your comment..."
        case .reply(let comment):
            return "Replying to \(comment.author.fullName)..."
        }
    }

    private var title: String {
        switch mode {
        case .create:
            return "Add Comment"
        case .edit:
            return "Edit Comment"
        case .reply:
            return "Reply to Comment"
        }
    }

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header (solo para edit/reply)
            if !isCreateMode {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.05))
            }

            // Input area
            HStack(alignment: .center, spacing: 12) {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                            onSave()
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.purple, lineWidth: 2)
                    )
                    .foregroundColor(.white)

                // Buttons
                HStack(spacing: 8) {
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.purple)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }

                    Button {
                        onSave()
                    } label: {
                        Text("Save")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        text.trimmingCharacters(in: .whitespaces).isEmpty
                                            ? Color.gray : Color.purple)
                            )
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding()
            .background(Color(white: 0.1))
        }
        .onAppear {
            isFocused = true
        }
    }

    private var isCreateMode: Bool {
        if case .create = mode {
            return true
        }
        return false
    }
}

#Preview {
    VStack(spacing: 20) {
        CommentInputView(
            mode: .create,
            text: .constant(""),
            onSave: {},
            onCancel: {}
        )

        CommentInputView(
            mode: .reply(Comment()),
            text: .constant("This is a reply"),
            onSave: {},
            onCancel: {}
        )
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
