import Foundation
import Photos
import Combine

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

    func updateFavoriteStatusAsync() {
        DispatchQueue.global().async {
            self.updateFavoriteStatus()
        }
    }
}
