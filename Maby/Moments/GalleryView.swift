import Aespa
import SwiftUI
import PhotosUI

struct GalleryView: View {
    @ObservedObject var viewModel: VideoContentViewModel
    @Binding private var mediaType: AssetType
    @State private var showingSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    init(
        mediaType: Binding<AssetType>,
        contentViewModel viewModel: VideoContentViewModel
    ) {
        self._mediaType = mediaType
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Picker("File", selection: $mediaType) {
                Text("Photo").tag(AssetType.photo)
                Text("Video").tag(AssetType.video)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            .padding(.vertical)
            
            ScrollView {
                switch mediaType {
                case .photo:
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 5
                    ) {
                        ForEach(viewModel.photoFiles) { file in
                            let image = file.image
                            
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                                   
                        
                    }
                    .onAppear {
                        viewModel.fetchPhotoFiles()
                    }
                case .video:
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 5
                    ) {
                        ForEach(viewModel.videoFiles) { file in
                            let image = file.thumbnailImage
                            
                            image
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .onAppear {
                        viewModel.fetchVideoFiles()
                    }
                
                }
            }
        }
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView(mediaType: .constant(.video), contentViewModel: .init())
    }
}
