import SwiftUI
import Photos
import AVKit
import AVFoundation

struct FullScreenImageView: View {
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            .aspectRatio(contentMode: .fit)
            .onDisappear {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
    }
}

struct VideoPlayerView: View {
    let url: URL
    @State private var player: AVPlayer = AVPlayer()

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                player.play()
            }
            .onDisappear {
                player.pause()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
    }
}