import AVKit
import SwiftUI

struct VideoPlayerView: View {
    let videoData: Data?
    let videoURL: URL?
    let autoPlay: Bool
    @State private var player: AVPlayer?

    init(videoData: Data? = nil, videoURL: URL? = nil, autoPlay: Bool = false) {
        self.videoData = videoData
        self.videoURL = videoURL
        self.autoPlay = autoPlay
    }

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .onAppear {
                        if autoPlay {
                            player.play()
                        }
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                // Loading state
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func setupPlayer() {
        if let videoURL = videoURL {
            // Video from URL
            player = AVPlayer(url: videoURL)
        } else if let videoData = videoData {
            // Video from data - save to temp file
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")

            do {
                try videoData.write(to: tempURL)
                player = AVPlayer(url: tempURL)
            } catch {
                print("Error writing video data: \(error)")
            }
        }
    }
}
