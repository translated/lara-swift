import Foundation

public struct DetectResult: Codable {
    public let language: String
    public let contentType: String

    private enum CodingKeys: String, CodingKey {
        case language
        case contentType = "content_type"
    }
}
