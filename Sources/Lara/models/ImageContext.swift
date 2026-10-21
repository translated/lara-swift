import Foundation

/// An HTTPS URL or base64 data URL containing a PNG, JPEG or WebP image.
public struct ImageContext: Codable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}

/// One image, supplied as an object or array. An empty array preserves text-only translation.
public enum ImageContextValue {
    case single(ImageContext)
    case multiple([ImageContext])

    func toJSON() -> Any {
        switch self {
        case .single(let image):
            return ["url": image.url]
        case .multiple(let images):
            return images.map { ["url": $0.url] }
        }
    }
}
