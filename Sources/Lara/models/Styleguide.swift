import Foundation

public class Styleguide: Codable {
    public let id: String
    public let name: String
    public let content: String?
    public let ownerId: String
    public let createdAt: Date
    public let updatedAt: Date
    public let sharedAt: Date
    public let isPersonal: Bool
    /// Effective combined mask in GET list/detail; selected share's stored mask in GET /shares.
    /// Nil when omitted, including non-GET responses.
    public let permissionMask: PermissionMask?

    init(id: String, name: String, content: String? = nil, ownerId: String, createdAt: Date, updatedAt: Date, sharedAt: Date, isPersonal: Bool = false, permissionMask: PermissionMask? = nil) {
        self.id = id
        self.name = name
        self.content = content
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sharedAt = sharedAt
        self.isPersonal = isPersonal
        self.permissionMask = permissionMask
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let content = try container.decodeIfPresent(String.self, forKey: .content)
        let ownerId = try container.decode(String.self, forKey: .ownerId)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        let sharedAt = try container.decode(Date.self, forKey: .sharedAt)
        // The API sends is_personal: true and omits the key otherwise; it never sends false or null,
        // so an absent field means "not personal".
        let isPersonal = try container.decodeIfPresent(Bool.self, forKey: .isPersonal) ?? false
        let permissionMask = try container.decodeIfPresent(PermissionMask.self, forKey: .permissionMask)

        self.init(id: id, name: name, content: content, ownerId: ownerId, createdAt: createdAt, updatedAt: updatedAt, sharedAt: sharedAt, isPersonal: isPersonal, permissionMask: permissionMask)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(sharedAt, forKey: .sharedAt)
        try container.encode(isPersonal, forKey: .isPersonal)
        try container.encodeIfPresent(permissionMask, forKey: .permissionMask)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case content
        case ownerId = "owner_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sharedAt = "shared_at"
        case isPersonal = "is_personal"
        case permissionMask = "permission_mask"
    }
}
