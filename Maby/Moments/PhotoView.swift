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
    @State var uiImage: UIImage?
    @State var image: PHAsset
    var images: [PHAsset]

    var body: some View {
        VStack {
            Text("Photo View")
                .font(.title)
                .foregroundColor(colorPink)
                .padding()
            if let uiImage = uiImage {
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
                            image = images[index]
                            getImage(from: image)
                        }) {
                            if let uiImage = uiImage {
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
        .onAppear {
            getImage(from: image)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavigationLink(destination: ParentView()) {
            Image(systemName: "arrow.backward")
                .foregroundColor(colorPink)
        }.onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        })
    }

    func getImage(from asset: PHAsset) {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.resizeMode = .exact
            manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { result, info in
                if let result = result {
                    uiImage = result
                }
            }
        }
}
