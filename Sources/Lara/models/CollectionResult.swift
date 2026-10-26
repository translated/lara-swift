import Foundation

public struct CollectionResult<T: Codable>: Codable {
    public let items: [T]
    /// Total number of matching resources.
    public let total: Int
    /// Current page (1-based).
    public let page: Int?
    /// Page size.
    public let size: Int?

    public init(items: [T], total: Int, page: Int? = nil, size: Int? = nil) {
        self.items = items
        self.total = total
        self.page = page
        self.size = size
    }
}
