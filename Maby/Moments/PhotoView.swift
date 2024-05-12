import Foundation
import SwiftUI
import Photos
import PhotosUI

struct PhotoView: View {
    let colorPink = Color(red: 246/255, green: 138/255, blue: 162/255)
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    @StateObject private var imageViewModel: ImageViewModel
    var image: PHAsset
    var images: [PHAsset]

    init(image: PHAsset, images: [PHAsset]) {
        self.image = image
        self.images = images
        _imageViewModel = StateObject(wrappedValue: ImageViewModel(asset: image))
    }

    var body: some View {
        VStack {
            Text("Photo View")
                .font(.title)
                .foregroundColor(colorPink)
                .padding()

            if let uiImage = imageViewModel.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.65)
            }

            ScrollView(.horizontal) {
                let rows = Array(repeating: GridItem(.fixed(75), spacing: 10), count: 2)
                LazyHGrid(rows: rows) {
                    ForEach(images.indices, id: \.self) { index in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            imageViewModel.fetchImage(for: images[index])
                        }) {
                            if let uiImage = imageViewModel.uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(10)
                                    .frame(width: 75, height: 75)
                                    .padding(.horizontal, 0)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavigationLink(destination: ParentView()) {
            Image(systemName: "arrow.backward")
                .foregroundColor(colorPink)
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        })
    }
}

class ImageViewModel: ObservableObject {
    @Published var uiImage: UIImage?
    private var asset: PHAsset

    init(asset: PHAsset) {
        self.asset = asset
        fetchImage(for: asset)
    }

    func fetchImage(for asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.resizeMode = .exact

        manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { [weak self] result, info in
            if let result = result {
                DispatchQueue.main.async {
                    self?.uiImage = result
                }
            }
        }
    }
}