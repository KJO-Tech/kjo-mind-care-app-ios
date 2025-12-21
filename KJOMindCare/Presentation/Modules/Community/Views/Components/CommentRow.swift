import SwiftUI

struct CommentRow: View {
    let comment: Comment
    let isMyComment: Bool
    let onReply: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color(hue: Double(comment.authorName.hashValue % 360) / 360.0, saturation: 0.6, brightness: 0.8))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(comment.authorName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Author name and time
                    HStack {
                        Text(comment.authorName)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        
                        Text(comment.createdAt.timeAgo)
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
                
                // Reply button
                Button {
                    onReply()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            // Edit/Delete actions for my comments
            if isMyComment {
                HStack(spacing: 16) {
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                    
                    Button {
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.leading, 48)
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
                                isMyComment: reply.authorId == "current-user-id",
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
            comment: Comment.mockList[0],
            isMyComment: true,
            onReply: {},
            onEdit: {},
            onDelete: {}
        )
        .padding()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
