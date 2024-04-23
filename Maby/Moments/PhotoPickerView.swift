import SwiftUI
import Photos
import PhotosUI
import UniformTypeIdentifiers

struct PhotoPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var media: [Media]
    @Binding var mostRecentVideoURL: URL?
    @Binding var mostRecentPhoto: UIImage?
    @Binding var showPhotoPicker: Bool

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func saveVideoToAlbum(_ url: URL) {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", "JOYFUL")
    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    if let joyfulAlbum = collections.firstObject {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .video, fileURL: url, options: nil)
            let placeHolder = creationRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: joyfulAlbum)
            albumChangeRequest?.addAssets([placeHolder!] as NSArray)
        }, completionHandler: nil)
    }
    }

    func saveImageToAlbum(_ image: UIImage) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "JOYFUL")
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let joyfulAlbum = collections.firstObject {
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: image.jpegData(compressionQuality: 1.0)!, options: nil)
                let placeHolder = creationRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: joyfulAlbum)
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            }, completionHandler: nil)
        }
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: PhotoPickerView

    init(_ parent: PhotoPickerView) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        parent.media.removeAll()
        parent.mostRecentPhoto = nil
        parent.mostRecentVideoURL = nil

        if let url = info[.mediaURL] as? URL, let asset = info[.phAsset] as? PHAsset {
            parent.saveVideoToAlbum(url)
            parent.media.append(Media(asset: asset, videoURL: url))
            if parent.mostRecentVideoURL == nil {
                parent.mostRecentVideoURL = url
            }
        } else if let image = info[.originalImage] as? UIImage, let asset = info[.phAsset] as? PHAsset {
            parent.media.append(Media(asset: asset, videoURL: nil))
            parent.saveImageToAlbum(image)
            parent.mostRecentPhoto = image
            if parent.mostRecentPhoto == nil {
                parent.mostRecentPhoto = image
            }
        }
        parent.showPhotoPicker = false
    }
}
}
