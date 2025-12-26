import SwiftUI
import UIKit

struct MediaPreviewView: View {
    let image: UIImage?
    let mediaUrl: String?
    let mediaType: MediaType?
    let cornerRadius: CGFloat
    let height: CGFloat?

    init(
        image: UIImage? = nil,
        mediaUrl: String? = nil,
        mediaType: MediaType? = nil,
        cornerRadius: CGFloat = 12,
        height: CGFloat? = 200
    ) {
        self.image = image
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
        self.cornerRadius = cornerRadius
        self.height = height
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
                case .IMAGE:
                    let secureUrl = urlString.replacingOccurrences(of: "http://", with: "https://")
                    AsyncImage(url: URL(string: secureUrl)) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            .frame(height: height ?? 200)
                            .cornerRadius(cornerRadius)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: height == nil ? .fit : .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: height)
                                .clipped()
                                .cornerRadius(cornerRadius)
                        case .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                case .VIDEO:
                    // Use actual video player instead of placeholder
                    let secureUrl = urlString.replacingOccurrences(of: "http://", with: "https://")
                    if let videoURL = URL(string: secureUrl) {
                        VideoPlayerView(videoURL: videoURL, autoPlay: false)
                            .cornerRadius(cornerRadius)
                    } else {
                        placeholderView
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
            mediaType: .IMAGE
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
