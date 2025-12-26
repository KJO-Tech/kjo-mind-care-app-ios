import FirebaseCore
import SwiftUI

struct BlogCard: View {
    let blog: Blog
    let categoryName: String?
    var onLike: (() -> Void)?
    var onShare: (() -> Void)?

            // Image Preview (Top)
    var mediaView: some View {
        Group {
            if let mediaUrl = blog.mediaUrl, let mediaType = blog.mediaType {
                switch mediaType {
                case .IMAGE:
                    let secureUrl = mediaUrl.replacingOccurrences(of: "http://", with: "https://")
                    AsyncImage(url: URL(string: secureUrl)) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(12)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .cornerRadius(12)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                case .VIDEO:
                    // Show video preview thumbnail
                    let secureUrl = mediaUrl.replacingOccurrences(of: "http://", with: "https://")
                    if let videoURL = URL(string: secureUrl) {
                        VideoPlayerView(videoURL: videoURL, autoPlay: false)
                            .frame(height: 200)
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Image Preview (Top)
            mediaView

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    // Avatar Logic
                    Group {
                        if let profileImage = blog.author.profileImage,
                            let url = URL(
                                string: profileImage.replacingOccurrences(
                                    of: "http://", with: "https://")), !profileImage.isEmpty
                        {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Circle().fill(Color.theme.primary)
                            }
                        } else {
                            Circle()
                                .fill(Color.theme.primary)
                                .overlay(
                                    Text(String(blog.author.fullName.prefix(1)))
                                        .font(.headline)
                                        .foregroundColor(Color.theme.text)
                                )
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(blog.author.fullName)
                            .foregroundColor(Color.theme.text)
                            .fontWeight(.medium)
                        Text(blog.getTimeAgo())  // Updated to relative time
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                    }

                    Spacer()
                }

                Text(blog.title)
                    .foregroundColor(Color.theme.text)
                    .font(.title3.bold())
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)  // Ensure leading alignment

                if !blog.content.isEmpty {
                    Text(blog.content)
                        .font(.body)
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                if let categoryName = categoryName {
                    Text(categoryName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.theme.primary.opacity(0.1))
                        .cornerRadius(8)
                } else if let categoryId = blog.categoryId {
                    Text(categoryId.capitalized)  // Fallback
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.theme.primary.opacity(0.1))
                        .cornerRadius(8)
                }

                Divider()
                    .background(Color.theme.textSecondary.opacity(0.3))

                HStack(spacing: 20) {
                    Button {
                        onLike?()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: blog.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(blog.isLiked ? Color.theme.primary : .gray)
                            Text("\(blog.likes)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }.padding(.vertical, 6)
                        .background(Color.theme.background.opacity(0.5))  // Subtle background
                        .cornerRadius(12)
                        .buttonStyle(BorderlessButtonStyle())

                    Button {
                        // Navigate to detail logic handled by parent tap
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                            Text("\(blog.comments)")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .disabled(true)
                    .foregroundColor(Color.theme.textSecondary)

                    Spacer()

                    Button {
                        onShare?()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .padding(8)
                            .background(Color.theme.primary.opacity(0.1))
                            .clipShape(Circle())
                            .foregroundColor(Color.theme.primary)

                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .font(.subheadline)
            }
            .padding()
        }
        .background(Color.theme.card)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 4)
    }
}

#Preview {
    BlogCard(
        blog: Blog(
            id: "1",
            title: "Preview Blog",
            content: "",
            author: User(uid: "1", fullName: "John Doe", email: "", role: ""),
            createdAt: Timestamp(date: Date()),
            updatedAt: Timestamp(date: Date()),
            likes: 10,
            reaction: 2,
            comments: 3,
            status: BlogStatus.PUBLISHED
        ), categoryName: "stress"
    ).preferredColorScheme(.light)
        .padding()
        .background(.black)
}
