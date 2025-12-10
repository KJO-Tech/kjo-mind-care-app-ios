import SwiftUI
import FirebaseCore

struct BlogCard: View {
    let blog: Blog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(blog.author.fullName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(blog.author.fullName)
                        .foregroundColor(.white)
                    Text(blog.getTimeAgo())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "arrow.2.squarepath")
                    .foregroundColor(.gray)
            }
            
            Text(blog.title)
                .foregroundColor(.white)
                .font(.title3.bold())
            
            Text(blog.categoryId ?? "Unknow")
                .font(.caption)
                .foregroundColor(.purple)
            
            HStack(spacing: 20) {
                Label("\(blog.likes)", systemImage: "heart")
                Label("\(blog.comments)", systemImage: "bubble.right")
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
    }
}

#Preview {
    let blog = Blog(
        id: "1",
        title: "Blog Title",
        content: "Blog Content",
        author: User(
            uid: "1",
            fullName: "John Doe", 
            email: "john.doe@example.com",
            role: "user", 
            profileImage: "https://example.com/profile.jpg"
        ),
        createdAt: Timestamp(date: Date()),
        likes: 10,
        comments: 5,
        categoryId: "category1"
    )
    BlogCard(blog: blog)
        .preferredColorScheme(.dark)
        .padding()
        .background(.black)
}
