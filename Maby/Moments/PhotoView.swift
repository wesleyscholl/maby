import SwiftUI
import Photos

struct PhotoView: View {
  var image: PHAsset
@State private var uiImage: UIImage?

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      if let uiImage = ImageCache.shared.getImage(for: image) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
          }
      } else {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
          .scaleEffect(2)
      }
    }
    .onAppear {
       ImageCache.shared.loadImage(for: image) { fetchedImage in
        // Update the state variable when the image is fetched
        self.uiImage = fetchedImage
      }
    }
  }
}

class ImageCache {
  static let shared = ImageCache()
  private var cache = NSCache<PHAsset, UIImage>()

  func getImage(for asset: PHAsset) -> UIImage? {
    return cache.object(forKey: asset)
  }

    func loadImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.resizeMode = .exact

    manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { [weak self] image, _ in
  guard let image = image else {
      print("Error fetching image from PHAssetManager")
      return
  }
  print("Image fetched for \(asset.localIdentifier)")  // Add this line
  self?.cache.setObject(image, forKey: asset)
        completion(image)
}
}
}
