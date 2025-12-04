import SwiftUI

struct BlogCard: View {
    let blog: Blog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(blog.authorName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(blog.authorName)
                        .foregroundColor(.white)
                    Text(blog.createdAt.timeAgo)
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
            
            Text(blog.category)
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
    BlogCard(blog: Blog.mockList.first!)
        .preferredColorScheme(.dark)
        .padding()
        .background(.black)
}
