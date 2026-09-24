import Foundation

/// Four corners of a paragraph or line, each an [x, y] pair of pixel coordinates.
public struct ImageBBox: Codable {
    public let topLeft: [Int]
    public let topRight: [Int]
    public let bottomRight: [Int]
    public let bottomLeft: [Int]

    public init(topLeft: [Int], topRight: [Int], bottomRight: [Int], bottomLeft: [Int]) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }

    private enum CodingKeys: String, CodingKey {
        case topLeft = "top_left"
        case topRight = "top_right"
        case bottomRight = "bottom_right"
        case bottomLeft = "bottom_left"
    }
}
