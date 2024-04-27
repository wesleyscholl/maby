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
    @State var image: PHAsset
    var images: [PHAsset]

    var body: some View {
        VStack {
            Image(uiImage: getImage(from: image))
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.65)
            ScrollView(.horizontal) {
                let rows = Array(repeating: GridItem(.fixed(75), spacing: 10), count: 2)
               LazyHGrid(rows: rows) {
                    ForEach(images.indices, id: \.self) { index in
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(uiImage: getImage(from: images[index]))
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(10)
                            .frame(width: 75, height: 75)
                            .padding(.horizontal, 0)
                            .onTapGesture {
                                image = images[index]
                                
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
        }.onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        })
    }

    func getImage(from asset: PHAsset) -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    option.isSynchronous = true
    var thumbnail = UIImage()
    manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
        thumbnail = result!
    })
    return thumbnail
}
}
