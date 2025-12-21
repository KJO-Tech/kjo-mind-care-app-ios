import SwiftUI

struct BlogDetailView: View {
    @StateObject var viewModel: BlogDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text(error)
                        .foregroundColor(.gray)
                    Button("Retry") {
                        Task {
                            await viewModel.loadBlog()
                        }
                    }
                    .padding()
                    .background(Color.theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if let blog = viewModel.blog {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Media (Image/Video)
                        if let mediaUrl = blog.mediaUrl, let url = URL(string: mediaUrl) {
                            if blog.mediaType == .VIDEO {
                                // Placeholder for Video - In a real app we'd use AVPlayer
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .frame(height: 250)
                                        .frame(maxWidth: .infinity)

                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                }
                            } else {
                                // Image
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(height: 250)
                                            .frame(maxWidth: .infinity)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 250)
                                            .frame(maxWidth: .infinity)
                                            .clipped()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 250)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            // Author and Date
                            HStack {
                                if let authorImage = blog.author.profileImage,
                                    let url = URL(string: authorImage)
                                {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text(blog.author.fullName)
                                        .font(.theme.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.theme.text)

                                    Text(blog.getTimeAgo())
                                        .font(.theme.caption)
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                            }

                            // Content
                            Text(blog.content)
                                .font(.theme.body)
                                .foregroundColor(Color.theme.text)
                                .lineSpacing(6)

                            Divider()
                                .padding(.vertical)

                            // Stats
                            HStack(spacing: 20) {
                                HStack(spacing: 4) {
                                    Image(systemName: "heart")
                                    Text("\(blog.likes)")
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: "bubble.right")
                                    Text("\(blog.comments)")
                                }

                                Spacer()
                            }
                            .font(.theme.subheadline)
                            .foregroundColor(Color.theme.textSecondary)
                        }
                        .padding()
                    }
                }
                .navigationTitle(blog.title)
            } else {
                EmptyView()  // Should have loaded or errored
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.theme.background)
        .ignoresSafeArea()
        .task {
            if viewModel.blog == nil {
                await viewModel.loadBlog()
            }
        }
    }
}
