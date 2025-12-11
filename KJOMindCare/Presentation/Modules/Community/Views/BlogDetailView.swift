import SwiftUI

struct BlogDetailView: View {
    @EnvironmentObject var coordinator: CommunityCoordinator
    @StateObject private var vm: BlogDetailViewModel
    
    init(blog: Blog) {
        _vm = StateObject(wrappedValue: BlogDetailViewModel(blog: blog))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                 
                    if vm.blog.mediaUrl != nil || vm.blog.mediaType != nil {
                        MediaPreviewView(
                            mediaUrl: vm.blog.mediaUrl,
                            mediaType: vm.blog.mediaType,
                            cornerRadius: 0
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text(vm.blog.title)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.top, 16)
                        
                    
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(vm.blog.authorName.prefix(1)))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(vm.blog.authorName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                
                                Text(vm.blog.createdAt.timeAgo)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        
                       
                        HStack(spacing: 24) {
                            Button {
                                vm.toggleLike()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: vm.isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(vm.isLiked ? .purple : .gray)
                                    Text("\(vm.likeCount)")
                                        .foregroundColor(.gray)
                                }
                                .font(.subheadline)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "bubble.right")
                                    .foregroundColor(.gray)
                                Text("\(vm.comments.count)")
                                    .foregroundColor(.gray)
                            }
                            .font(.subheadline)
                            
                            Button {
                                
                            } label: {
                                Text("Share button")
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.purple.opacity(0.2))
                                    )
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                      
                        Text(vm.blog.content)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 16)
                        
                        
                        if vm.isMyBlog {
                            HStack(spacing: 12) {
                                Button {
                                    vm.editBlog()
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
                                    vm.deleteBlog()
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
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                    
                        HStack {
                            Text("Comments (\(vm.comments.count))")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        
                        Button {
                            vm.addComment()
                        } label: {
                            Text("Add comment")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.purple)
                                )
                        }
                        .padding(.bottom, 16)

                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(vm.comments) { comment in
                                CommentRow(
                                    comment: comment,
                                    isMyComment: vm.isMyComment(comment),
                                    onReply: {
                                        vm.replyToComment(comment)
                                    },
                                    onEdit: {
                                        vm.editComment(comment)
                                    },
                                    onDelete: {
                                        vm.deleteComment(comment)
                                    }
                                )
                                
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                        .padding(.bottom, 100) //
                    }
                    .padding(.horizontal)
                }
            }
            
            if vm.showCommentInput {
                CommentInputView(
                    mode: vm.commentMode,
                    text: $vm.commentText,
                    onSave: {
                        vm.saveComment()
                    },
                    onCancel: {
                        vm.cancelComment()
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Share
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
        }
        .overlay {
            if vm.showDeleteDialog {
                DeleteConfirmationDialog(
                    title: vm.itemToDelete == .blog ? "Delete Blog" : "Delete Comment",
                    message: vm.itemToDelete == .blog ?
                        "Are you sure you want to delete this blog? This action cannot be undone." :
                        "Are you sure you want to delete this comment? This action cannot be undone.",
                    onDelete: {
                        if case .blog = vm.itemToDelete {
                            vm.confirmDeleteBlog()
                            coordinator.pop()
                        } else {
                            vm.confirmDeleteComment()
                        }
                    },
                    onCancel: {
                        vm.showDeleteDialog = false
                        vm.itemToDelete = nil
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: vm.showCommentInput)
        .animation(.easeInOut, value: vm.showDeleteDialog)
    }
}

#Preview {
    NavigationView {
        BlogDetailView(blog: Blog.mockList[1])
    }
    .preferredColorScheme(.dark)
}
