import Foundation

public class Glossary: Codable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let sharedAt: Date
    public let name: String
    public let ownerId: String
    /// Effective combined mask in GET list/detail; selected share's stored mask in GET /shares.
    /// Nil when omitted, including non-GET responses.
    public let permissionMask: PermissionMask?

    init(id: String, createdAt: Date, updatedAt: Date, sharedAt: Date, name: String, ownerId: String, permissionMask: PermissionMask? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sharedAt = sharedAt
        self.name = name
        self.ownerId = ownerId
        self.permissionMask = permissionMask
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        let sharedAt = try container.decode(Date.self, forKey: .sharedAt)
        let name = try container.decode(String.self, forKey: .name)
        let ownerId = try container.decode(String.self, forKey: .ownerId)
        let permissionMask = try container.decodeIfPresent(PermissionMask.self, forKey: .permissionMask)

        self.init(id: id, createdAt: createdAt, updatedAt: updatedAt, sharedAt: sharedAt, name: name, ownerId: ownerId, permissionMask: permissionMask)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(sharedAt, forKey: .sharedAt)
        try container.encode(name, forKey: .name)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encodeIfPresent(permissionMask, forKey: .permissionMask)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sharedAt = "shared_at"
        case name
        case ownerId = "owner_id"
        case permissionMask = "permission_mask"
    }
}
