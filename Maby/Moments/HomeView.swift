import SwiftUI
import UIKit
import Photos
import PhotosUI
import MabyKit
import AVKit
import AVFoundation
import Combine
import FloatingButton
import LinkPresentation
import PermissionsSwiftUI

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct HomeView: View {
    @State private var colorSchemeGender: GenderColorScheme = .getColorScheme(for: .other)
    @FetchRequest(fetchRequest: allBabies) private var babies: FetchedResults<Baby>
    private var gender: Baby.Gender {
        babies.first?.gender ?? .other
    }
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
    @State private var showingShareSheet = false
    @State private var showReactionsBackground = false
    @State private var linkMetadata: LPLinkMetadata?
    @State private var mediaType: AssetType = .photo
    @State private var isLoadingImages = true
    @State private var showPermissionsModal = false 
    @State private var imageToShare: UIImage? = nil
    
    @State private var reactions = [
        Reaction(imageName: "heart.fill", isShown: false, rotation: 360, isSelected: false),
        Reaction(imageName: "hand.thumbsup.fill", isShown: false, rotation: 360, isSelected: false),
        Reaction(imageName: "hand.thumbsdown.fill", isShown: false, rotation: 360, isSelected: false),
        Reaction(imageName: "star.fill", isShown: false, rotation: 360, isSelected: false),
        Reaction(imageName: "exclamationmark.2", isShown: false, rotation: 360, isSelected: false),
        Reaction(imageName: "questionmark", isShown: false, rotation: 360, isSelected: false)
    ]
    
    let viewModel = VideoContentViewModel()
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
            let reversedAssets = assets.objects(at: IndexSet(integersIn: 0..<assets.count)).sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() })
            processAssets(reversedAssets)
        }
        DispatchQueue.main.async {
            isLoadingImages = false
        }
    }

    private func processAssets(_ assets: [PHAsset]) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.resizeMode = .none
        option.deliveryMode = .highQualityFormat
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addOperation {
            assets.forEach { asset in
                DispatchQueue.main.async {
                    if !self.images.contains(asset) {
                        self.images.append(asset)
                        self.observableAssets[asset.localIdentifier] = ObservablePHAsset(asset: asset)
                    }
                    if asset.mediaType == .video {
                        processVideoAsset(asset, manager)
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

    private func processVideoAsset(_ asset: PHAsset, _ manager: PHImageManager) {
        manager.requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
            if let avAsset = avAsset as? AVURLAsset {
                DispatchQueue.main.async {
                    let newMedia = Media(asset: asset, videoURL: avAsset.url)
                    if !self.media.contains(where: { $0.asset == newMedia.asset }) {
                        self.media.append(newMedia)
                    }
                    self.mostRecentVideoURL = avAsset.url
                }
            }
        }
    }

    func getImage(from asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .exact
        var image: UIImage?
        manager.requestImage(for: asset, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFill, options: options) { result, _ in
            image = result
        }
        return image ?? UIImage()
    }

    func fetchMostRecentMedia() {
        guard !hasFetchedMedia && !isUpdatingFavoriteStatus else {
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", "JOYFUL")
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            if let album = albums.firstObject {
                let assets = PHAsset.fetchAssets(in: album, options: nil)
                let sortedAssets = assets.objects(at: IndexSet(integersIn: 0..<assets.count)).sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() })
                if let asset = sortedAssets.first {
                    processMostRecentAsset(asset)
                }
            }
        }
    }

    private func processMostRecentAsset(_ asset: PHAsset) {
        if asset.mediaType == .image {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFill, options: nil) { image, _ in
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
        } else if asset.mediaType == .video {
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

func fetchURLPreview(url: URL) {
    let metadataProvider = LPMetadataProvider()
    metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
        if let error = error {
            // Handle the error gracefully, provide a default metadata object
            let defaultMetadata = LPLinkMetadata()
            defaultMetadata.title = "Your Title Here"
            defaultMetadata.originalURL = url
            defaultMetadata.url = url
            DispatchQueue.main.async {
                self.linkMetadata = defaultMetadata
                self.showingShareSheet = true
            }
            return
        }

        guard let data = metadata, data.originalURL != nil else {
            // Handle the case where no metadata is available
            let defaultMetadata = LPLinkMetadata()
            defaultMetadata.title = "Your Title Here"
            defaultMetadata.originalURL = url
            defaultMetadata.url = url
            DispatchQueue.main.async {
                self.linkMetadata = defaultMetadata
                self.showingShareSheet = true
            }
            return
        }

        DispatchQueue.main.async {
            let modifiedMetadata = LPLinkMetadata()
            modifiedMetadata.title = "Your Custom Title Here"
            modifiedMetadata.originalURL = data.originalURL
            modifiedMetadata.url = data.url

            // If you have a UIImage for the thumbnail
            if let thumbnailImage = UIImage(named: "your_thumbnail_image") {
                modifiedMetadata.imageProvider = NSItemProvider(object: thumbnailImage)
            }
            self.linkMetadata = modifiedMetadata
            self.showingShareSheet = true
        }
    }
}

func handleButtonAction(with asset: PHAsset) {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    if asset.mediaType == .image {
        handleImageAsset(asset)
    } else if asset.mediaType == .video {
        handleVideoAsset(asset)
    }
}

    func handleImageAsset(_ asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { (image, info) in
            if let image = image {
                DispatchQueue.main.async {
                    self.selectedMedia = .image(image)
                    let shareItem = ShareItem(
                        title: "Custom Title for \(asset.creationDate?.formatted() ?? "Image")",
                        bodyText: "Custom description for \(asset.creationDate?.formatted() ?? "Image")",
                        thumbnail: image.thumbnailImage(maxSize: CGSize(width: 100, height: 100)),
                        contentURL: URL(string: "https://\(asset.localIdentifier).com"),
                        image: image,
                        data: nil
                    )
                    self.showingShareSheet = true
                }
            }
        }
    }

    func handleVideoAsset(_ asset: PHAsset) {
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avAsset, _, _) in
            if let urlAsset = avAsset as? AVURLAsset {
                DispatchQueue.main.async {
                    self.fetchURLPreview(url: urlAsset.url)
                    self.selectedMedia = .video(urlAsset.url)
                    let shareItem = ShareItem(
                        title: "Custom Title for \(asset.creationDate?.formatted() ?? "Video")",
                        bodyText: "Custom description for \(asset.creationDate?.formatted() ?? "Video")",
                        thumbnail: nil, // No thumbnail for videos
                        contentURL: URL(string: "https://\(urlAsset.url).com"),
                        image: nil,
                        data: nil
                    )
                    self.showingShareSheet = true
                }
            }
        }
    }
    
   private func buttonsView(for asset: ObservablePHAsset) -> some View {
    HStack(spacing: 60) {
        if let identifier = selectedImageIdentifier, let asset = observableAssets[identifier] {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                asset.updateFavoriteStatusAsync()
            } label: {
                Image(systemName: asset.isFavorite == true ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(asset.isFavorite == true ? colorSchemeGender.dark : .white)
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
                            Gradient(colors: [colorSchemeGender.medium, colorSchemeGender.dark]), startPoint: .topLeading, endPoint: .bottomTrailing))
              .clipShape(Circle())
              .font(.system(size: 25))
              .frame(width: 60, height: 60)
              .rotationEffect(.degrees(isOpen ? 45 : 0))
              .animation(.spring(), value: isOpen)
        
        let buttons: [AnyView] = [
            AnyView(Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.showPhotoPicker = true
            }) {
              Image(systemName: "photo.stack")
            }
            .frame(width: 50, height: 50)
            .background(LinearGradient(gradient:
                            Gradient(colors: [colorSchemeGender.dark, colorSchemeGender.medium]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(Circle())
            .foregroundColor(.white)),
          AnyView(Button(action: {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              self.isPhotoPresented = true
          }) {
              Image(systemName: "photo.badge.plus.fill")
            }
            .frame(width: 50, height: 50)
            .background(LinearGradient(gradient:
                            Gradient(colors: [colorSchemeGender.dark, colorSchemeGender.medium]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(Circle())
            .foregroundColor(.white)),
          AnyView(Button(action: {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              self.isVideoPresented = true
          }) {
              Image(systemName: "video.fill.badge.plus")
            }
            .frame(width: 50, height: 50)
            .background(LinearGradient(gradient:
                            Gradient(colors: [colorSchemeGender.dark, colorSchemeGender.medium]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(Circle())
            .foregroundColor(.white))
        ]
        NavigationView {
            VStack(spacing: 0) {
                Spacer()
                VStack {
                    if let media = mostRecentMedia {
                        switch media {
                        case .photo(let image):
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: isFullScreen ? screenWidth * 1.1 : screenWidth, height: isFullScreen ? screenHeight * 0.43 : screenHeight * 0.32)
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
                                .frame(width: isFullScreen ? screenWidth * 1.1 : screenWidth, height: isFullScreen ? screenHeight * 0.43 : screenHeight * 0.32)
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
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.32)
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
                                                        Gradient(colors: [colorSchemeGender.medium, colorSchemeGender.light]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: screenWidth, height: screenHeight * 0.32)
                                .cornerRadius(8)
                                .shadow(color: lightGray, radius: 4)
                            VStack {
                                HStack {
                                    Text("Tap")
                                    Image(systemName: "plus")
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
                        if isLoadingImages {
                            ForEach(0..<10) { _ in
                                ProgressView()
            .frame(width: 75, height: 75)
            .cornerRadius(8)
            .shadow(color: lightGray, radius: 2)
                            }
                            } else {
                            ForEach(images.indices, id: \.self) { index in
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
                                              if images[index].mediaType == .image {
                                                let options = PHImageRequestOptions()
                                                options.isSynchronous = false
                                                PHImageManager.default().requestImage(for: images[index], targetSize: CGSize(width: images[index].pixelWidth, height: images[index].pixelHeight), contentMode: .aspectFill, options: options) { (image, info) in
                                                  guard let image = image else { return }
                                                  DispatchQueue.main.async {
                                                    let shareItems = [image]
                                                    let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                                       let window = windowScene.windows.first {
                                                      window.rootViewController?.present(activityViewController, animated: true, completion: nil)
                                                    }
                                                  }
                                                }
                                              }
                                            }) {
                                              Text("Share")
                                              Image(systemName: "square.and.arrow.up")
                                            }
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                observableAsset.updateFavoriteStatus()
                                            }) {
                                                Text(observableAsset.isFavorite == true ? "Deselect" : "Favorite")
                                                Image(systemName: observableAsset.isFavorite == true ? "heart.fill" : "heart")
                                            }
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    if images[index].mediaType == .image {
                                                        let options = PHImageRequestOptions()
                                                        options.isSynchronous = false
                                                        PHImageManager.default().requestImage(for: images[index], targetSize: CGSize(width: images[index].pixelWidth, height: images[index].pixelHeight), contentMode: .aspectFill, options: options) { (image, info) in
                                                            if let image = image {
                                                                DispatchQueue.main.async {
                                                                    self.selectedMedia = .image(image)
                                                                    self.showingMedia = true
                                                                }
                                                            }
                                                        }
                                                    } else if images[index].mediaType == .video {
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
                                        .gesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                            self.selectedMedia = .image(getImage(from: images[index]))
                                            self.showingMedia = true
                                        })
                                        .sheet(isPresented: $showingMedia) {
                                            if let media = selectedMedia {
                                                switch media {
                                                case .image(let image):
                                                    FullScreenImageView(image: image)
                                                case .video(let videoURL):
                                                    VideoPlayerView(url: videoURL)
                                                }
                                            }
                                        }
                                        .sheet(isPresented: $showingShareSheet) {
                                            if let media = selectedMedia {
                                                switch media {
                                                case .image(let image):
                                                    let shareItem = ShareItem(
                                                        title: "Custom Title for \(asset.creationDate?.formatted() ?? "Image")",
                                                        bodyText: "Custom description for \(asset.creationDate?.formatted() ?? "Image")",
                                                        thumbnail: image.thumbnailImage(maxSize: CGSize(width: 100, height: 100)),
                                                        contentURL: nil,
                                                        image: image,
                                                        data: nil
                                                    )
                                                    ShareSheet(shareItem: shareItem)
                                                case .video(let videoURL):
                                                    let shareItem = ShareItem(
                                                        title: "Custom Title for \(asset.creationDate?.formatted() ?? "Video")",
                                                        bodyText: "Custom description for \(asset.creationDate?.formatted() ?? "Video")",
                                                        thumbnail: nil,
                                                        contentURL: videoURL,
                                                        image: nil,
                                                        data: nil
                                                    )
                                                    ShareSheet(shareItem: shareItem)
                                                }
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
                    }
                    .flipsForRightToLeftLayoutDirection(true)
                    .onAppear(perform: loadImages)
                    .padding(10)
                }
                Divider().overlay(colorSchemeGender.medium).opacity(0.25)
                    ZStack {
                        ReactionBackgroundView(showReactionsBackground: $showReactionsBackground)
                        ReactionBarView(reactions: $reactions)
                    }
                    .padding(.bottom, 5)
                HStack {
                    Button(action: {
                        withAnimation {
                            symbolAnimate.toggle()
                        }
                    }) {
                        Image(systemName: "photo.stack.fill")
                            .hidden()
                            .foregroundColor(colorSchemeGender.dark)
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                            .foregroundStyle(darkGrey)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        symbolAnimate.toggle()
                                    }
                                }
                            }
                            .symbolEffect(.bounce.down, options: .repeat(2).speed(0.1), value: symbolAnimate)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Button(action: {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        self.isPhotoPresented = true
                    }) {
                        ZStack() {
                            Circle()
                                .fill(colorSchemeGender.light)
                                .frame(width: 120, height: 120)
//                                .shadow(color: Color(UIColor.lightGray), radius: 5, x: 0, y: 5)
                                .overlay(
                                    Circle()
                                        .stroke(colorSchemeGender.medium, lineWidth: 4)
//                                        .shadow(color: Color(lightGray), radius: 3, x: 0, y: 3)
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
                                .background(LinearGradient(colorSchemeGender.medium, colorSchemeGender.light))
                                .foregroundStyle(.white)
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
                    VStack {
                        Spacer()
                        Spacer()
                        FloatingButton(mainButtonView: mainButton, buttons: buttons, isOpen: $isOpen)
                            .circle()
                            .startAngle(3/2 * .pi)
                            .endAngle(2 * .pi)
                            .radius(67)
                            .layoutDirection(.counterClockwise)
                            .delays(delayDelta: 0.1)
                            .shadow(color: Color(.gray).opacity(0.3), radius: 2, x: 0, y: 2)
                            .onChange(of: isOpen, {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        showReactionsBackground.toggle()
                                        if reactions.first(where: { $0.isShown }) != nil {
                                            for index in reactions.indices.reversed() {
                                                withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.1 * Double(reactions.count - index))) {
                                                    reactions[index].isShown.toggle()
                                                }
                                            }
                                        } else {
                                            for index in reactions.indices {
                                                withAnimation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.1 * Double(index + 1))) {
                                                    reactions[index].isShown.toggle()
                                                }
                                            }
                                        }
                            })
                    }
                }
                Spacer()
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
            self.colorSchemeGender = .getColorScheme(for: self.gender)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onChange(of: gender) { newGender in
                    self.colorSchemeGender = .getColorScheme(for: newGender)
                }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Image(systemName: "video.badge.plus")
            .foregroundColor(colorSchemeGender.dark)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.isVideoPresented = true
            },trailing: Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showPhotoPicker = true
            }) {
                Image(systemName: "photo.badge.plus")
                    .foregroundColor(colorSchemeGender.dark)
            }
        )
    }
}
