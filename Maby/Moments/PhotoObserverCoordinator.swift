import SwiftUI
import Foundation
import Photos

class Coordinator: NSObject, PHPhotoLibraryChangeObserver {
    var parent: HomeView

    init(_ parent: HomeView) {
        self.parent = parent
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.parent.loadImagesAndFetchMostRecentMedia()
        }
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