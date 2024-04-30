import SwiftUI
import UIKit
import Photos
import PhotosUI
import AVKit
import AVFoundation
import Combine

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

enum PhotoOrVideoMedia {
    case photo(UIImage)
    case video(URL)
}

struct Media: Equatable {
    var asset: PHAsset
    var videoURL: URL?

    static func ==(lhs: Media, rhs: Media) -> Bool {
        return lhs.asset == rhs.asset && lhs.videoURL == rhs.videoURL
    }
}

class Coordinator: NSObject, PHPhotoLibraryChangeObserver {
    var parent: HomeView

    init(_ parent: HomeView) {
        self.parent = parent
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.parent.loadImages()
            self.parent.fetchMostRecentMedia()
        }
    }
}

struct HomeView: View {
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    @Environment(\.colorScheme) var colorScheme
    @State private var isPresented = false
    @State private var images: [PHAsset] = []
    @State var showPhotoPicker = false
    @State private var mostRecentPhoto: UIImage?
    @State private var selectedImage: PHAsset?
    @State private var showingImage = false
    @State private var videoURL: URL? = nil
    @State var media: [Media] = []
    @State private var coordinator: Coordinator?
    @State private var mostRecentVideoURL: URL?
    @State private var isFullScreen = false
    @State private var player: AVPlayer? = nil
    @State private var mostRecentMedia: PhotoOrVideoMedia?
    @State private var selectedVideoID: String?
    @State private var isPressed = false
    @State private var selectedAsset: ObservablePHAsset? 
    @State private var isUpdatingFavoriteStatus = false
    @State private var hasFetchedMedia = false
    @State private var observableAssets = [String: ObservablePHAsset]()
    @State private var selectedImageIdentifier: String?

    let colorPink = Color(red: 246/255, green: 138/255, blue: 162/255)
    let mediumPink = Color(red: 255/255, green: 193/255, blue: 206/255)
    let lightPink = Color(red: 254/255, green: 242/255, blue: 242/255)
    let darkColor = Color(red: 78/255, green: 0/255, blue: 25/255)
    let lightGray = Color(red: 230/255, green: 224/255, blue: 225/255)

func loadImages() {
    self.images = []
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", "JOYFUL")
    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    if let joyfulAlbum = collections.firstObject {
        let assets = PHAsset.fetchAssets(in: joyfulAlbum, options: nil)
        let reversedAssets = assets.objects(at: IndexSet(integersIn: 0..<assets.count)).sorted { $0.creationDate ?? Date() > $1.creationDate ?? Date() }
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.resizeMode = .none
        option.deliveryMode = .highQualityFormat
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addOperation {
            for object in reversedAssets {
                DispatchQueue.main.async {
                    if !self.images.contains(object) {
                        self.images.append(object)
                        self.observableAssets[object.localIdentifier] = ObservablePHAsset(asset: object)
                    }
                    if object.mediaType == .video {
                        manager.requestAVAsset(forVideo: object, options: nil) { (avAsset, _, _) in
                            if let avAsset = avAsset as? AVURLAsset {
                                DispatchQueue.main.async {
                                    let newMedia = Media(asset: object, videoURL: avAsset.url)
                                    if !self.media.contains(where: { $0.asset == newMedia.asset }) {
                                        self.media.append(newMedia)
                                    }
                                    self.mostRecentVideoURL = avAsset.url
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    if let firstAsset = self.images.first {
                        self.selectedAsset = ObservablePHAsset(asset: firstAsset)
                    }
                }
            }
        }
    }
}
        
        func getImage(from asset: PHAsset) -> UIImage {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            var thumbnail = UIImage()
            manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                thumbnail = result!
            })
            return thumbnail
        }

func fetchMostRecentMedia() {
    if !hasFetchedMedia && !isUpdatingFavoriteStatus {
    DispatchQueue.global(qos: .userInteractive).async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "JOYFUL")
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let album = albums.firstObject {
            let assets = PHAsset.fetchAssets(in: album, options: nil)
            let sortedAssets = assets.objects(at: IndexSet(integersIn: 0..<assets.count)).sorted { $0.creationDate ?? Date() > $1.creationDate ?? Date() }
            if let asset = sortedAssets.first {
                if asset.mediaType == .image {
                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: screenWidth * 0.95, height: screenHeight * 0.35), contentMode: .aspectFill, options: nil) { image, _ in
                        DispatchQueue.main.async {
                            if let image = image {
                                self.mostRecentPhoto = image
                                self.mostRecentMedia = .photo(image)
                                if !self.images.contains(asset) {
                                    self.images.insert(asset, at: 0)
                                }
                                self.selectedImageIdentifier = asset.localIdentifier
                                self.hasFetchedMedia = true
                            }
                        }
                    }
                }
                if asset.mediaType == .video {
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
                        if let avAsset = avAsset as? AVURLAsset {
                            DispatchQueue.main.async {
                                self.mostRecentVideoURL = avAsset.url
                                self.mostRecentMedia = .video(avAsset.url)
                                if !self.images.contains(asset) {
                                    self.images.insert(asset, at: 0)
                                }
                                self.selectedImageIdentifier = asset.localIdentifier
                                self.hasFetchedMedia = true
                            }
                        }
                    }
                }
            }
        }
    }
}
}

class ObservablePHAsset: ObservableObject {
    @Published var isFavorite: Bool
    let asset: PHAsset
    init(asset: PHAsset) {
        self.asset = asset
        self.isFavorite = asset.isFavorite
    }
    func updateFavoriteStatus() {
        PHPhotoLibrary.shared().performChanges({
            let changeRequest = PHAssetChangeRequest(for: self.asset)
            changeRequest.isFavorite = !self.asset.isFavorite
        }, completionHandler: { success, error in
            if success {
                DispatchQueue.main.async {
                    self.isFavorite = !self.isFavorite
                }
            } else if let error = error {
                print("Error updating asset: \(error)")
            }
        })
    }
}

private func buttonsView(for asset: ObservablePHAsset) -> some View {
    HStack(spacing: 60) {
     if let identifier = selectedImageIdentifier, let asset = observableAssets[identifier] {
            Button {
                asset.updateFavoriteStatus()
            } label: {
                Image(systemName: asset.isFavorite == true ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(asset.isFavorite == true ? colorPink : .white)
                    .scaleEffect(isPressed ? 4.0 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: isPressed)
            }
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                withAnimation {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    isPressed = pressing
                }
            }, perform: {})
        }
    }
}
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                VStack {
                    if let media = mostRecentMedia {
                        switch media {
                        case .photo(let image):
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: isFullScreen ? screenHeight * 0.5 : screenHeight * 0.35, height: isFullScreen ? screenHeight * 0.5 : screenHeight * 0.35)
                                .cornerRadius(8)
                                .shadow(color: lightGray, radius: 4)
                                .onTapGesture {
                                    withAnimation {
                                        isFullScreen.toggle()
                                    }
                                }
                                .overlay(alignment: .bottom) {
                                    if let asset = selectedAsset {
                                    buttonsView(for: asset)
                                        .offset(x: 0, y: -20)
                                }
                                }
                        case .video(let videoURL):
                                VideoPlayer(player: player)
                                    .id(selectedVideoID)
                                    .scaledToFill()
                                    .frame(width: isFullScreen ? screenHeight * 0.5 : screenHeight * 0.35, height: isFullScreen ? screenHeight * 0.5 : screenHeight * 0.35)
                                    .cornerRadius(8)
                                    .shadow(color: lightGray, radius: 4)
                                    .onTapGesture {
                                        withAnimation {
                                            isFullScreen.toggle()
                                        }
                                    }
                                    .onAppear {
                                            player = AVPlayer(url: videoURL)
                                            player?.play()
                                    }
                                    .onDisappear {
                                            player?.pause()
                                    }
                                    .onChange(of: selectedVideoID) { newValue in
                                        if let videoURL = mostRecentVideoURL {
                                            player = AVPlayer(url: videoURL)
                                            player?.play()
                                        }
                                    }
                                    .overlay(alignment: .bottom) {
                                        if let asset = selectedAsset {
                                    buttonsView(for: asset)
                                        .offset(x: 0, y: -20)
                                }
                                    }
                    }
                } else if let asset = images.first {
                    Image(uiImage: getImage(from: asset))
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenHeight * 0.35, height: screenHeight * 0.35)
                        .cornerRadius(8)
                        .shadow(color: lightGray, radius: 4)
                        .overlay(alignment: .bottom) {
                             if let asset = selectedAsset {
                            buttonsView(for: asset)
                            .offset(x: 0, y: -20)
                             }
                        }
                } else {
                    Text("Tap + to add a photo or video")
                        .font(.system(size: 35))
                        .foregroundStyle(.white)
                        .frame(width: screenHeight * 0.35, height: screenHeight * 0.35)
                        .cornerRadius(8)
                        .shadow(color: lightGray, radius: 4)
                        .multilineTextAlignment(.center)
                        .background(LinearGradient(mediumPink, lightPink))
                    }
                }.onAppear {
                    fetchMostRecentMedia()
                    if let videoURL = mostRecentVideoURL {
                    player = AVPlayer(url: videoURL)
                }
                }
                ScrollView(.horizontal) {
                    let rows = Array(repeating: GridItem(.fixed(75), spacing: 10), count: 2)
                    LazyHGrid(rows: rows) {
                        if images.isEmpty {
                            ForEach(0..<30, id: \.self) { _ in
                                Image("lilyan")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 75, height: 75)
                                    .cornerRadius(8)
                                    .shadow(color: lightGray, radius: 2)
                            }
                        } else {
                            ForEach(images.indices, id: \.self) { index in
                                NavigationLink(destination: PhotoView(image: images[index], images: images)) {
                                    let asset = images[index]
                                    let observableAsset = ObservablePHAsset(asset: asset)
                                    Image(uiImage: getImage(from: asset))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .cornerRadius(8)
                                        .shadow(color: lightGray, radius: 2)
                                        .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        self.selectedImageIdentifier = asset.localIdentifier
                                        selectedAsset = ObservablePHAsset(asset: asset)
                                        if asset.mediaType == .video {
                                            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
                                                if let avAsset = avAsset as? AVURLAsset {
                                                    self.mostRecentMedia = .video(avAsset.url)
                                                    self.mostRecentVideoURL = avAsset.url
                                                    self.mostRecentPhoto = nil
                                                    self.player = AVPlayer(url: avAsset.url)
                                                    self.selectedVideoID = asset.localIdentifier
                                                }
                                            }
                                        } else {
                                        self.mostRecentMedia = .photo(getImage(from: images[index]))
                                        self.mostRecentPhoto = getImage(from: images[index])
                                        self.mostRecentVideoURL = nil
                                        self.player = nil
                                        }
                                        self.isPressed = false
                                        }
                                        .contextMenu { 
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                observableAsset.updateFavoriteStatus()
                                            }) {
                                                Text(observableAsset.isFavorite == true ? "Deselect" : "Favorite")
                                                Image(systemName: observableAsset.isFavorite == true ? "heart.fill" : "heart")
                                            }
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                self.selectedImage = images[index]
                                                self.showingImage = true
                                            }) {
                                                Text("View")
                                                Image(systemName: "eye")
                                            }
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                let assetToDelete = images[index]
                                                images.remove(at: index)
                                                PHPhotoLibrary.shared().performChanges({
                                                    PHAssetChangeRequest.deleteAssets([assetToDelete] as NSArray)
                                                }, completionHandler: { success, error in
                                                    if success {
                                                        DispatchQueue.main.async {
                                                            if images.isEmpty {
                                                                mostRecentPhoto = nil
                                                                mostRecentVideoURL = nil
                                                            } else {
                                                                fetchMostRecentMedia()
                                                            }
                                                        }
                                                    } else if let error = error {
                                                        print("Error deleting asset: \(error)")
                                                    }
                                                })
                                                }) {
                                                Text("Delete")
                                                Image(systemName: "trash")
                                                }
                                        }
                                        .overlay(alignment: .bottomLeading) {
                                            if asset.isFavorite {
                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(.white)
                                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                                                    .font(.callout)
                                                    .offset(x: 4, y: -4)
                                            }
                                        }
                                    }
                                    }.sheet(isPresented: $showingImage) {
                                    if let selectedImage = selectedImage {
                                    PhotoView(image: selectedImage, images: images).onDisappear {
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    }
                                }
                            }
                        }
                    }
                    .flipsForRightToLeftLayoutDirection(true)
                    .onAppear(perform: loadImages)
                    .padding(10)
                }
                Divider().overlay(mediumPink).opacity(0.25)
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    self.isPresented = true
                }) {
                    ZStack() {
                        Circle()
                            .fill(lightPink)
                            .frame(width: 120, height: 120)
                            .shadow(color: Color(UIColor.lightGray), radius: 5, x: 0, y: 5)
                            .overlay(
                                Circle()
                                    .stroke(mediumPink, lineWidth: 4)
                                    .shadow(color: Color(lightGray), radius: 3, x: 0, y: 3)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .scaleEffect(0.9)
                            )
                        Image(systemName: "camera")
                            .font(.system(size: 50))
                            .frame(width: 100, height: 100)
                            .shadow(color: Color(lightGray), radius: 1, x: 0, y: 1)
                            .background(LinearGradient(mediumPink, lightPink))
                            .foregroundStyle(colorPink)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                            )
                    }
                }
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            }.sheet(isPresented: $isPresented) {
                VideoContentView(isPresented: $isPresented)
            }
            .onChange(of: isPresented) { newValue in
            if !newValue {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(media: $media, mostRecentVideoURL: $mostRecentVideoURL, mostRecentPhoto: $mostRecentPhoto, showPhotoPicker: $showPhotoPicker)
                    .onDisappear {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
            }.navigationBarBackButtonHidden(true)
                .onAppear {
                    coordinator = Coordinator(self)
                }
        }.onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        // .navigationBarTitle("Joyful")
        // .navigationBarTitleDisplayMode(.inline)
        // .navigationBarBackButtonHidden(true)
        // .navigationBarItems(leading:
        // Image(systemName: "video.badge.plus")
        //     .foregroundColor(colorPink)
        //     .onTapGesture {
        //         UIImpactFeedbackGenerator(style: .light).impactOccurred()
        //         self.isPresented = true
        //     },trailing: Button(action: {
        //             UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        //             showPhotoPicker = true
        //         }) {
        //             Image(systemName: "photo.badge.plus")
        //                 .foregroundColor(colorPink)
        //         }
        //     )
    }
}

class PhotoLibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver, ObservableObject {
    var onChange: (() -> Void)?

    init(onChange: @escaping () -> Void) {
        self.onChange = onChange
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.onChange?()
        }
    }
}
