import Foundation

public struct ResourceQueryOptions {
    /// Filter resources by their visible name. Enables pagination when provided.
    public var search: String?
    /// Page number (1-based). Enables pagination when provided.
    public var page: Int?
    /// Page size (1–200). Enables pagination when provided.
    public var size: Int?

    public init(search: String? = nil, page: Int? = nil, size: Int? = nil) {
        self.search = search
        self.page = page
        self.size = size
    }

    public func toParams() -> [String: Any] {
        var params: [String: Any] = [:]
        if let search = self.search {
            params["search"] = search
        }
        if let page = self.page {
            params["page"] = page
        }
        if let size = self.size {
            params["size"] = size
        }
        return params
    }
}
