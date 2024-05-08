import SwiftUI
import UIKit
import Photos
import PhotosUI
import AVKit
import AVFoundation
import Combine
import FloatingButton

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

struct FullScreenImageView: View {
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
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

enum SelectedMedia {
    case image(UIImage)
    case video(URL)
}

struct HomeView: View {
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    @Environment(\.colorScheme) var colorScheme
    @State private var isPhotoPresented = false
    @State private var isVideoPresented = false
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
    @State private var selectedMedia: SelectedMedia?
    @State private var showingMedia = false
    @State private var symbolAnimate = false
    @State private var isTextVisible = false
    @State private var isOpen = false
    
    @State private var showReactionsBackground = false
    @State private var showLike = false
    @State private var showThumbsUp = false
    @State private var thumbsUpRotation: Double = -45 // 🤔
    @State private var showThumbsDown = false
    @State private var thumbsDownRotation: Double = -45 // 🤔
    @State private var showLol = false
    @State private var showWutReaction = false
    @State private var showStarReaction = false
    
    var isThumbsUpRotated: Bool {
      thumbsUpRotation == -45
    }

    var isThumbsDownRotated: Bool {
      thumbsDownRotation == -45
    }
    
    let inboundBubbleColor = Color(#colorLiteral(red: 0.07058823529, green: 0.07843137255, blue: 0.0862745098, alpha: 1))
    let reactionsBGColor = Color(#colorLiteral(red: 0.07058823529, green: 0.07843137255, blue: 0.0862745098, alpha: 1))
    
    let colorPink = Color(red: 246/255, green: 138/255, blue: 162/255)
    let mediumPink = Color(red: 255/255, green: 193/255, blue: 206/255)
    let lightPink = Color(red: 254/255, green: 242/255, blue: 242/255)
    let darkColor = Color(red: 78/255, green: 0/255, blue: 25/255)
    let lightGray = Color(red: 230/255, green: 224/255, blue: 225/255)
    let darkGrey = Color(red: 128/255, green: 128/255, blue: 128/255)
    
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
        let mainButton: some View = Image(systemName: "plus")
            .foregroundColor(.white)
              .padding()
              .background(LinearGradient(gradient:
                            Gradient(colors: [mediumPink, colorPink]), startPoint: .topLeading, endPoint: .bottomTrailing))
              .clipShape(Circle())
              .font(.system(size: 25))
              .frame(width: 60, height: 60)
              .rotationEffect(.degrees(isOpen ? 45 : 0))
              .animation(.spring())
        
        let buttons: [AnyView] = [
            AnyView(Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.showPhotoPicker = true
            }) {
              Image(systemName: "photo.stack")
            }
            .frame(width: 50, height: 50)
            .background(lightPink)
            .clipShape(Circle())
            .foregroundColor(colorPink)),
          AnyView(Button(action: {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              self.isPhotoPresented = true
          }) {
              Image(systemName: "photo.badge.plus.fill")
            }
            .frame(width: 50, height: 50)
            .background(mediumPink)
            .clipShape(Circle())
            .foregroundColor(darkGrey)),
          AnyView(Button(action: {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              self.isVideoPresented = true
          }) {
              Image(systemName: "video.fill.badge.plus")
            }
            .frame(width: 50, height: 50)
            .background(colorPink)
            .clipShape(Circle())
            .foregroundColor(.white))
        ]
        NavigationView {
            VStack(spacing: 10) {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(UIColor.tertiarySystemGroupedBackground))
                            .frame(width: 240, height: 40)
                            .scaleEffect(showReactionsBackground ? 1 : 0, anchor: .bottomTrailing)
                            .animation(
                                .interpolatingSpring(stiffness: 170, damping: 15).delay(0.05),
                                value: showReactionsBackground
                            )
                        HStack(spacing: 20) {
                            Image(systemName: "heart.fill")
                                .scaleEffect(showLike ? 1 : 0)
                                .rotationEffect(.degrees(showLike ? 720 : 0))
                            Image(systemName: "hand.thumbsup.fill")
                                .scaleEffect(showThumbsUp ? 1 : 0)
                                .rotationEffect(.degrees(thumbsUpRotation))
                            Image(systemName: "hand.thumbsdown.fill")
                                .scaleEffect(showThumbsDown ? 1 : 0)
                                .rotationEffect(.degrees(thumbsDownRotation))
                            Image(systemName: "star.fill")
                                .scaleEffect(showStarReaction ? 1 : 0)
                                .rotationEffect(.degrees(showStarReaction ? 360 : 0)) // Rotate the star
//                                .scaleEffect(showStarReaction ? 1.5 : 1) // Bounce the star
                            Image(systemName: "exclamationmark.2")
                                .scaleEffect(showLol ? 1 : 0)
                                .rotationEffect(.degrees(showLol ? 0 : 360))
                            Image(systemName: "questionmark")
                                .scaleEffect(showWutReaction ? 1 : 0)
                                .rotationEffect(.degrees(showWutReaction ? 360 : 0))
                        }
                    }.padding(.bottom, 2)
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
                                .onLongPressGesture {
                                    showReactionsBackground.toggle()
                                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.15)) {
                                        showLike.toggle()
                                    }
                                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.3)) {
                                        showThumbsUp.toggle()
                                        thumbsUpRotation = isThumbsUpRotated ? 0 : -45
                                    }
                                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.45)) {
                                        showThumbsDown.toggle()
                                        thumbsDownRotation = isThumbsDownRotated ? 0 : -45
                                    }
                                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.6)) {
                                        showStarReaction.toggle()
                                    }
                                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.75)) {
                                        showLol.toggle()
                                    }
                                    withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.9)) {
                                        showWutReaction.toggle()
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
                        ZStack {
                            Rectangle()
                                .fill(LinearGradient(gradient:
                                                        Gradient(colors: [mediumPink, lightPink]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: screenHeight * 0.35, height: screenHeight * 0.35)
                                .cornerRadius(8)
                                .shadow(color: lightGray, radius: 4)
                            VStack {
                                HStack {
                                    Text("Tap")
                                    Image(systemName: "camera")
                                    Image(systemName: "video.badge.plus")
                                    Text("or")
                                    Image(systemName: "photo.badge.plus")
                                }
                                .font(.system(size: 18))
                                .foregroundStyle(darkGrey)
                                .multilineTextAlignment(.center)
                                .padding()
                                .opacity(isTextVisible ? 0.7 : 0)
                                .animation(Animation.easeIn.delay(0.5))
                                Text("to add photos or videos")
                                    .font(.system(size: 18))
                                    .foregroundStyle(darkGrey)
                                    .multilineTextAlignment(.center)
                                    .opacity(isTextVisible ? 0.7 : 0)
                                    .animation(Animation.easeIn.delay(1))
                            }
                        }.onAppear {
                            isTextVisible = true
                        }
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
                                                let asset = images[index]
                                                if asset.mediaType == .image {
                                                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil) { (image, _) in
                                                        if let image = image {
                                                            DispatchQueue.main.async {
                                                                self.selectedMedia = .image(image)
                                                                self.showingMedia = true
                                                            }
                                                        }
                                                    }
                                                } else if asset.mediaType == .video {
                                                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
                                                        if let urlAsset = avAsset as? AVURLAsset {
                                                            DispatchQueue.main.async {
                                                                self.selectedMedia = .video(urlAsset.url)
                                                                self.showingMedia = true
                                                            }
                                                        }
                                                    }
                                                }
                                            }) {
                                                Text("View")
                                                Image(systemName: "photo")
                                            }
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                let assetToRemove = images[index]
                                                DispatchQueue.main.async {
                                                    images.remove(at: index)
                                                }
                                                PHPhotoLibrary.shared().performChanges({
                                                    let fetchOptions = PHFetchOptions()
                                                    fetchOptions.predicate = NSPredicate(format: "title = %@", "JOYFUL")
                                                    if let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject {
                                                        let changeRequest = PHAssetCollectionChangeRequest(for: album)
                                                        changeRequest?.removeAssets([assetToRemove] as NSArray)
                                                    }
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
                                                        print("Error removing asset from album: \(error)")
                                                    }
                                                })
                                            }) {
                                                Text("Remove from Album")
                                                Image(systemName: "trash")
                                            }
                                            Button(role: .destructive, action: {
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
                            }
                            .sheet(isPresented: $showingMedia) {
                                if let selectedMedia = selectedMedia {
                                    switch selectedMedia {
                                    case .image(let image):
                                        FullScreenImageView(image: image)
                                    case .video(let videoURL):
                                        VideoPlayerView(url: videoURL)
                                            .edgesIgnoringSafeArea(.all)
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
                Spacer().frame(height: 20)
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            symbolAnimate.toggle()
                        }
                    }) {
                        Image(systemName: "photo.stack.fill")
                            .hidden()
                            .foregroundColor(colorPink)
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
//                            .shadow(color: Color(lightGray), radius: 1, x: 0, y: 1)
                            .foregroundStyle(darkGrey)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        symbolAnimate.toggle()
                                    }
                                }
                            }
                            .symbolEffect(.bounce.down, options: .repeat(2).speed(0.1), value: symbolAnimate)
//                            .symbolEffect(.variableColor.reversing.cumulative, options: .repeat(3).speed(3), value: symbolAnimate)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        self.isPhotoPresented = true
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
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                        FloatingButton(mainButtonView: mainButton, buttons: buttons, isOpen: $isOpen)
                            .circle()
                            .startAngle(3/2 * .pi)
                            .endAngle(2 * .pi)
                            .radius(70)
                            .layoutDirection(.counterClockwise)
                            .delays(delayDelta: 0.1)
                            .shadow(color: Color(.gray).opacity(0.3), radius: 2, x: 0, y: 2)
                    Spacer()
                }
            }.sheet(isPresented: $isVideoPresented) {
                VideoContentView(isPresented: $isVideoPresented, captureMode: .video)
            }
            .sheet(isPresented: $isPhotoPresented) {
                VideoContentView(isPresented: $isPhotoPresented, captureMode: .photo)
            }
            .onChange(of: isVideoPresented) { newValue in
                if !newValue {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onChange(of: isPhotoPresented) { newValue in
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Image(systemName: "video.badge.plus")
            .foregroundColor(colorPink)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.isVideoPresented = true
            },trailing: Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showPhotoPicker = true
            }) {
                Image(systemName: "photo.badge.plus")
                    .foregroundColor(colorPink)
            }
        )
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
