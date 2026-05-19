import Foundation

public class Styleguide: Codable {
    public let id: String
    public let name: String
    public let content: String?
    public let ownerId: String
    public let createdAt: Date
    public let updatedAt: Date
    public let isPersonal: Bool?

    init(id: String, name: String, content: String? = nil, ownerId: String, createdAt: Date, updatedAt: Date, isPersonal: Bool? = nil) {
        self.id = id
        self.name = name
        self.content = content
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPersonal = isPersonal
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let content = try container.decodeIfPresent(String.self, forKey: .content)
        let ownerId = try container.decode(String.self, forKey: .ownerId)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        let isPersonal = try container.decodeIfPresent(Bool.self, forKey: .isPersonal)

        self.init(id: id, name: name, content: content, ownerId: ownerId, createdAt: createdAt, updatedAt: updatedAt, isPersonal: isPersonal)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(isPersonal, forKey: .isPersonal)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case content
        case ownerId = "owner_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isPersonal = "is_personal"
    }
}
