import SwiftUI
import UIKit

struct BlogDetailView: View {
    @StateObject var viewModel: BlogDetailViewModel
    @EnvironmentObject var coordinator: CommunityCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let mediaUrl = viewModel.blog?.mediaUrl {
                        MediaPreviewView(
                            mediaUrl: mediaUrl,
                            mediaType: viewModel.blog?.mediaType,
                            cornerRadius: 0,
                            height: nil  // Allow full height/aspect ratio
                        )
                    }

                    if let blog = viewModel.blog {
                        VStack(alignment: .leading, spacing: 16) {
                            headerView(blog: blog)
                            statsView(blog: blog)
                            contentView(blog: blog)

                            Divider().background(Color.gray.opacity(0.3))

                            commentsSection
                        }
                        .padding(.horizontal)
                    } else if viewModel.isLoading {
                        ProgressView().padding()
                    } else {
                        emptyStateView
                    }
                }
            }
            .refreshable { await viewModel.loadData() }

            if viewModel.showCommentInput {
                commentInputOverlay
            }
        }
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {  // Add spacing between icons
                    if viewModel.isMyBlog {
                        Button {
                            if let blog = viewModel.blog {
                                coordinator.showEditBlog(blog: blog)
                            }
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(Color.theme.primary)
                        }

                        Button {
                            viewModel.deleteBlog()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(Color.red)
                        }
                    }

                    shareButton(blog: viewModel.blog)
                }
            }
        }
        .overlay { deleteDialogOverlay }
        .animation(.easeInOut, value: viewModel.showCommentInput)
        .animation(.easeInOut, value: viewModel.showDeleteDialog)
        .task {
            if viewModel.blog == nil { await viewModel.loadData() }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func headerView(blog: Blog) -> some View {
        Text(blog.title)
            .font(.title2.bold())
            .foregroundColor(Color.theme.text)
            .padding(.top, 16)

        HStack(spacing: 12) {
            if let profileImage = blog.author.profileImage, !profileImage.isEmpty,
                let url = URL(
                    string: profileImage.replacingOccurrences(of: "http://", with: "https://"))
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    case .failure(_):
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                            )
                    case .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Circle()
                    .fill(Color.theme.primary.opacity(0.6))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(viewModel.authorName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.authorName)
                    .font(.subheadline.bold())
                    .foregroundColor(Color.theme.text)

                HStack {
                    Text(blog.getTimeAgo())
                        .font(.caption)
                        .foregroundColor(Color.theme.textSecondary)

                    if !viewModel.categoryName.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                        Text(viewModel.categoryName)
                            .font(.caption.bold())
                            .foregroundColor(Color.theme.primary)
                    }
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func statsView(blog: Blog) -> some View {
        HStack(spacing: 24) {
            Button {
                viewModel.toggleLike()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isLiked ? Color.theme.primary : .gray)
                    Text("\(viewModel.likeCount)")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
            }

            HStack(spacing: 6) {
                Image(systemName: "bubble.right")
                // Use actual loaded comments count if available, otherwise fallback to blog metadata
                Text(
                    "\(viewModel.comments.isEmpty ? (viewModel.blog?.comments ?? 0) : viewModel.totalCommentsCount)"
                )
            }
            .foregroundColor(.gray)
            .font(.subheadline)

            shareActionButton(blog: blog)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func shareActionButton(blog: Blog) -> some View {
        Button {
            presentShareSheet(blog: blog)
        } label: {
            Text("Share")
                .font(.subheadline)
                .foregroundColor(Color.theme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.theme.primary.opacity(0.2))
                )
        }
    }

    @ViewBuilder
    private func contentView(blog: Blog) -> some View {
        Text(blog.content)
            .font(.body)
            .foregroundColor(Color.theme.text.opacity(0.9))
            .padding(.bottom, 16)
    }

    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.editBlog()
            } label: {
                Label("Edit Blog", systemImage: "pencil")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.3))
                    )
            }

            Button {
                viewModel.deleteBlog()
            } label: {
                Label("Delete Blog", systemImage: "trash")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.3))
                    )
            }
        }
        .padding(.bottom, 16)
    }

    private var commentsSection: some View {
        VStack {
            HStack {
                Text(
                    "Comments (\(viewModel.comments.isEmpty ? (viewModel.blog?.comments ?? 0) : viewModel.totalCommentsCount))"
                )
                .font(.headline)
                .foregroundColor(Color.theme.text)
                Spacer()
            }
            .padding(.vertical, 12)

            Button {
                viewModel.addComment()
            } label: {
                Text("Add comment")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.theme.primary)
                    )
            }
            .padding(.bottom, 16)

            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.comments) { comment in
                    CommentRow(
                        comment: comment,
                        currentUserId: viewModel.currentUserId,
                        onReply: { viewModel.replyToComment(comment) },
                        onEdit: { viewModel.editComment(comment) },
                        onDelete: { viewModel.deleteComment(comment) }
                    )
                    Divider().background(Color.gray.opacity(0.2))
                }
            }
            .padding(.bottom, 100)
        }
    }

    private var emptyStateView: some View {
        VStack {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(Color.theme.textSecondary)
                .padding()
            Text("No details found for this blog.")
                .foregroundColor(Color.theme.textSecondary)
        }
        .padding()
    }

    private var commentInputOverlay: some View {
        CommentInputView(
            mode: viewModel.commentMode,
            text: $viewModel.commentText,
            onSave: { Task { await viewModel.saveComment() } },
            onCancel: { viewModel.cancelComment() }
        )
        .transition(.move(edge: .bottom))
    }

    @ViewBuilder
    private var deleteDialogOverlay: some View {
        if viewModel.showDeleteDialog {
            DeleteConfirmationDialog(
                title: viewModel.itemToDelete == .blog ? "Delete Blog" : "Delete Comment",
                message: viewModel.itemToDelete == .blog
                    ? "Are you sure you want to delete this blog? This action cannot be undone."
                    : "Are you sure you want to delete this comment? This action cannot be undone.",
                onDelete: {
                    if case .blog = viewModel.itemToDelete {
                        viewModel.confirmDeleteBlog()
                        coordinator.pop()
                    } else {
                        viewModel.confirmDeleteComment()
                    }
                },
                onCancel: {
                    viewModel.showDeleteDialog = false
                    viewModel.itemToDelete = nil
                }
            )
            .transition(.opacity)
        }
    }

    @ViewBuilder
    private func shareButton(blog: Blog?) -> some View {
        if let blog = blog {
            Button {
                presentShareSheet(blog: blog)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color.theme.primary)
            }
        }
    }

    private func presentShareSheet(blog: Blog) {
        let shareText = "Check out this blog: \(blog.title)"
        let shareUrl = URL(string: "https://kjomindcare.netlify.app/app/community/post/\(blog.id)")!
        let activityVC = UIActivityViewController(
            activityItems: [shareText, shareUrl],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        {
            rootVC.present(activityVC, animated: true)
        }
    }
}
