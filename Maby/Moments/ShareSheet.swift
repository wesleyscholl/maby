import SwiftUI
import LinkPresentation

class ShareItem: NSObject, UIActivityItemSource {
    let title: String
    let bodyText: String?
    let thumbnail: UIImage?
    let contentURL: URL?
    let image: UIImage?
    let data: Data?

    init(title: String, bodyText: String? = nil, thumbnail: UIImage? = nil, contentURL: URL? = nil, image: UIImage? = nil, data: Data? = nil) {
        self.title = title
        self.bodyText = bodyText
        self.thumbnail = thumbnail
        self.contentURL = contentURL
        self.image = image
        self.data = data
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return title
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .mail {
            let mailData = "\(title)\n\n\(bodyText ?? "")\n\(contentURL?.absoluteString ?? "")"
            return mailData.data(using: .utf8)
        } else if let image = image {
            return image
        } else if let data = data {
            return data
        } else if let contentURL = contentURL {
            return contentURL
        } else {
            return title
        }
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return thumbnail
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var shareItem: ShareItem
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [shareItem], applicationActivities: applicationActivities)
        return activityViewController
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}