import Foundation

/// Original text direction (ltr, rtl, or ttb) and colors.
public struct ImageTextInfo: Codable {
    public let direction: String
    public let textColor: String
    public let backgroundColor: String

    public init(direction: String, textColor: String, backgroundColor: String) {
        self.direction = direction
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    private enum CodingKeys: String, CodingKey {
        case direction
        case textColor = "text_color"
        case backgroundColor = "background_color"
    }
}
