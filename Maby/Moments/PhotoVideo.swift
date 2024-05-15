import SwiftUI
import Photos
import AVKit
import AVFoundation

struct Media: Equatable {
    var asset: PHAsset
    var videoURL: URL?

    static func ==(lhs: Media, rhs: Media) -> Bool {
        return lhs.asset == rhs.asset && lhs.videoURL == rhs.videoURL
    }
}

extension UIImage {
    func thumbnailImage(maxSize: CGSize) -> UIImage? {
        let maxResolution = max(maxSize.width, maxSize.height)
        let scale = maxResolution / max(size.width, size.height)

        let thumbnailSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(thumbnailSize, true, 0.0)
        draw(in: CGRect(origin: .zero, size: thumbnailSize))
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return thumbnailImage
    }
}

enum PhotoOrVideoMedia {
    case photo(UIImage)
    case video(URL)
}

enum SelectedMedia {
        case image(UIImage)
        case video(URL)
    }