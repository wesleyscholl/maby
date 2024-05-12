//import SwiftUI
//import Photos
//import AVKit
//import AVFoundation
//
//struct MediaView: View {
//    enum MediaType {
//        case image(UIImage)
//        case video(URL)
//    }
//    
//    let media: MediaType
//    let joyfulMedia: [PHAsset]?
//    @State private var player: AVPlayer = AVPlayer()
//    
//    func getImage(from asset: PHAsset) -> UIImage {
//    let manager = PHImageManager.default()
//    let options = PHImageRequestOptions()
//    options.isSynchronous = true
//    options.resizeMode = .exact
//    var image: UIImage?
//    manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { result, info in
//        if let result = result {
//            image = result
//        }
//    }
//    return image!
//}
//    
//    var body: some View {
//        switch media {
//        case .image(let image):
//            Image(uiImage: image)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .onDisappear {
//                    UINotificationFeedbackGenerator().notificationOccurred(.success)
//                }
//        case .video(let url):
//            VideoPlayer(player: AVPlayer(url: url))
//                .onAppear {
//                    player.play()
//                }
//            // Grid at the bottom
//            ScrollView(.horizontal) {
//                if let joyfulMedia = joyfulMedia {
//                    let rows = Array(repeating: GridItem(.fixed(60), spacing: 10), count: 3)
//                    LazyHGrid(rows: [GridItem(.gridRow(min: 60, max: 60)), GridItem(.gridRow(min: 60, max: 60)) {
//                          ForEach(joyfulMedia) { asset in
//                            // Check if asset is a video
//                            if asset.mediaType == .video {
//                              // Display video icon (replace with your desired icon)
//                              Image(systemName: "play.circle")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 50, height: 50)
//                                .foregroundColor(.gray)
//                            } else {
//                              // Get image thumbnail for image assets
//                              let image = getImage(from: asset)
//
//                              // Display the thumbnail image
//                              Image(uiImage: image)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 50, height: 50) // Adjust size as needed
//                                .clipped() // Clip to avoid exceeding frame size
//                            }
//                          }
//                        }
//                                     }
//                                     }
//                    .padding(.bottom)
//                
//                    .onDisappear {
//                        player.pause()
//                        UINotificationFeedbackGenerator().notificationOccurred(.success)
//                    }
//            }
//        }
//    }
//}
