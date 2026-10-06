import Foundation

public struct ResourceShareEntry: Codable {
    public let id: String
    public let name: String
    public let shareName: String
    public let sharedAt: Date
    /// The permissions stored on this share.
    public let permissionMask: PermissionMask

    init(id: String, name: String, shareName: String, sharedAt: Date, permissionMask: PermissionMask) {
        self.id = id
        self.name = name
        self.shareName = shareName
        self.sharedAt = sharedAt
        self.permissionMask = permissionMask
    }

    private enum CodingKeys: String, CodingKey {
        case id, name
        case permissionMask = "permission_mask"
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
