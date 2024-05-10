import SwiftUI
import Photos

struct CardItem: Identifiable {
    let id: Int
    let image: Image
}

struct ScrollTransitionView: View {
    @State var cards: [CardItem] = []
    let colorPink = Color(red: 246/255, green: 138/255, blue: 162/255)
    let mediumPink = Color(red: 255/255, green: 193/255, blue: 206/255)
    let lightPink = Color(red: 254/255, green: 242/255, blue: 242/255)
    let lightGray = Color(red: 230/255, green: 224/255, blue: 225/255)
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(cards) { card in
                    card.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height - 100) 
                        .cornerRadius(5)
//                        .overlay(RoundedRectangle(cornerRadius: 25.0).stroke(Color.white))
                        .background(Color.clear)
                        .shadow(color: Color(lightGray), radius: 3, x: 0, y: 3)
                        .containerRelativeFrame(.horizontal)
                        .scrollTransition (axis: .horizontal) {
                            content, phase in
                            content
                                .scaleEffect(x: phase.isIdentity ? 1 : 0.65, y: phase.isIdentity ? 1 : 0.65)
                                .rotation3DEffect(.degrees(phase.value * -10.0), axis: (x: phase.value, y: 1, z: -1))
                        
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadImages()
        }
        .scrollIndicators(.hidden)
        .background(LinearGradient(colors: [colorPink, lightPink], startPoint: .top, endPoint: .bottom))
        
    }
    func loadImages() {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", "JOYFUL")
    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    if let album = collection.firstObject {
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        assets.enumerateObjects { (asset, index, stop) in
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                if let image = result {
                    cards.append(CardItem(id: index, image: Image(uiImage: image)))
                }
            })
        }
    }
}
}
