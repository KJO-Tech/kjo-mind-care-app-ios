import SwiftUI
import FirebaseCore

struct BlogCard: View {
    let blog: Blog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.primarySoft)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(blog.author.fullName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(Color.text)
                    )
                
                VStack(alignment: .leading) {
                    Text(blog.author.fullName)
                        .foregroundColor(Color.text)
                    Text(blog.getLocalDateTime().formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.2.squarepath")
                    .foregroundColor(Color.textSecondary)
            }
            
            Text(blog.title)
                .foregroundColor(Color.text)
                .font(.title3.bold())
            
            Text(blog.categoryId ?? "")
                .font(.caption)
                .foregroundColor(Color.secondary)
            
            HStack(spacing: 20) {
                Label("\(blog.likes)", systemImage: "heart")
                Label("\(blog.comments)", systemImage: "bubble.right")
                
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
            }
            .foregroundColor(Color.textSecondary)
        }
        .padding()
        .background(Color.card)
        .cornerRadius(18)
    }
}

#Preview {
    BlogCard(blog: Blog(
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
    )).preferredColorScheme(.light)
    .padding()
    .background(.black)
}
