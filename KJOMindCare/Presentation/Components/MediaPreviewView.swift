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
                            ProgressView()
                                .frame(height: height ?? 200)
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

                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: height ?? 200)
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
            mediaType: .IMAGE
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
