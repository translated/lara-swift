import Foundation

public class Glossary: Codable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let name: String
    public let ownerId: String

    init(id: String, createdAt: Date, updatedAt: Date, name: String, ownerId: String) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.ownerId = ownerId
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        let name = try container.decode(String.self, forKey: .name)
        let ownerId = try container.decode(String.self, forKey: .ownerId)

        self.init(id: id, createdAt: createdAt, updatedAt: updatedAt, name: name, ownerId: ownerId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(name, forKey: .name)
        try container.encode(ownerId, forKey: .ownerId)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case ownerId = "owner_id"
    }
}
