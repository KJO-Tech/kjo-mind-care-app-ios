import SwiftUI

struct CommentRow: View {
    let comment: Comment
    let currentUserId: String  // Changed from isMyComment to allow recursive calculation
    let onReply: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                Circle()
                    .fill(
                        Color(
                            hue: Double(comment.author.fullName.hashValue % 360) / 360.0,
                            saturation: 0.6, brightness: 0.8)
                    )
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(comment.author.fullName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    // Author name and time
                    HStack {
                        Text(comment.author.fullName)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)

                        Text(comment.getTimeAgo())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    // Comment content
                    Text(comment.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Actions
                HStack(spacing: 16) {
                    if comment.isMine {
                        Button {
                            onEdit()
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.purple)
                                .font(.caption)
                        }

                        Button {
                            onDelete()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    Button {
                        onReply()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }

            // Replies
            if !comment.replies.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(comment.replies) { reply in
                        HStack(alignment: .top, spacing: 0) {
                            // Indentation line
                            Rectangle()
                                .fill(Color.purple.opacity(0.3))
                                .frame(width: 2)
                                .padding(.leading, 18)

                            CommentRow(
                                comment: reply,
                                currentUserId: currentUserId,
                                onReply: { onReply() },
                                onEdit: { onEdit() },
                                onDelete: { onDelete() }
                            )
                            .padding(.leading, 12)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack {
        CommentRow(
            comment: Comment(),
            currentUserId: "test-user-id",
            onReply: {},
            onEdit: {},
            onDelete: {}
        )
        .padding()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
