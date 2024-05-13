import SwiftUI
import Photos

struct PhotoView: View {
    var image: PHAsset
    
    init(image: PHAsset) {
        self.image = image
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let uiImage = getImage(from: image) {
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
    }
}

func getImage(from asset: PHAsset) -> UIImage? {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = true
    options.resizeMode = .exact
    var image: UIImage?
    manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { result, info in
        if let result = result {
            image = result
        }
    }
    return image
}
