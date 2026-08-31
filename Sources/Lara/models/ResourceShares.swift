import Foundation

public struct SharePermission: RawRepresentable, Codable, Hashable, Sendable {
    public static let read = SharePermission(rawValue: "read")
    public static let readWrite = SharePermission(rawValue: "read_write")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct ResourceShareEntry: Codable {
    public let id: String
    public let name: String
    public let shareName: String
    public let sharedAt: Date
    public let permissions: SharePermission

    private enum CodingKeys: String, CodingKey {
        case id, name, permissions
        case shareName = "share_name"
        case sharedAt = "shared_at"
    }
}

public struct MemoryShares: Codable {
    public let memory: Memory
    public let account: ResourceShareEntry?
    public let groups: [ResourceShareEntry]
    public let users: [ResourceShareEntry]
}

public struct GlossaryShares: Codable {
    public let glossary: Glossary
    public let account: ResourceShareEntry?
    public let groups: [ResourceShareEntry]
    public let users: [ResourceShareEntry]
}

public struct StyleguideShares: Codable {
    public let styleguide: Styleguide
    public let account: ResourceShareEntry?
    public let groups: [ResourceShareEntry]
    public let users: [ResourceShareEntry]
}
