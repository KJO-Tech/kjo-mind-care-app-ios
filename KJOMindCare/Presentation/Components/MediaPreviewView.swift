import SwiftUI

struct MediaPreviewView: View {
    let image: UIImage?
    let mediaUrl: String?
    let mediaType: MediaType?
    let cornerRadius: CGFloat
    
    init(
        image: UIImage? = nil,
        mediaUrl: String? = nil,
        mediaType: MediaType? = nil,
        cornerRadius: CGFloat = 12
    ) {
        self.image = image
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let image = image {
           
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(cornerRadius)
            } else if let urlString = mediaUrl, let mediaType = mediaType {
                
                switch mediaType {
                case .image:
                    AsyncImage(url: URL(string: urlString)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(cornerRadius)
                        case .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                case .video:
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .cornerRadius(cornerRadius)
                        
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 200)
            .cornerRadius(cornerRadius)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        MediaPreviewView(
            image: UIImage(systemName: "photo")
        )
        
        MediaPreviewView(
            mediaUrl: "https://example.com/image.jpg",
            mediaType: .image
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
