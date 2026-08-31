import Foundation

public class Memory: Codable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let sharedAt: Date
    public let name: String
    public let externalId: String?
    public let secret: String?
    public let ownerId: String
    public let collaboratorsCount: Int
    public let isPersonal: Bool

    init(id: String, createdAt: Date, updatedAt: Date, sharedAt: Date, name: String, externalId: String?, secret: String?, ownerId: String, collaboratorsCount: Int, isPersonal: Bool = false) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sharedAt = sharedAt
        self.name = name
        self.externalId = externalId
        self.secret = secret
        self.ownerId = ownerId
        self.collaboratorsCount = collaboratorsCount
        self.isPersonal = isPersonal
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(String.self, forKey: .id)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        let sharedAt = try container.decode(Date.self, forKey: .sharedAt)
        let name = try container.decode(String.self, forKey: .name)
        let externalId = try container.decodeIfPresent(String.self, forKey: .externalId)
        let secret = try container.decodeIfPresent(String.self, forKey: .secret)
        let ownerId = try container.decode(String.self, forKey: .ownerId)
        let collaboratorsCount = try container.decode(Int.self, forKey: .collaboratorsCount)
        // The API sends is_personal: true and omits the key otherwise; it never sends false or null,
        // so an absent field means "not personal".
        let isPersonal = try container.decodeIfPresent(Bool.self, forKey: .isPersonal) ?? false
        
        self.init(id: id, createdAt: createdAt, updatedAt: updatedAt, sharedAt: sharedAt, name: name, externalId: externalId, secret: secret, ownerId: ownerId, collaboratorsCount: collaboratorsCount, isPersonal: isPersonal)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(sharedAt, forKey: .sharedAt)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(externalId, forKey: .externalId)
        try container.encodeIfPresent(secret, forKey: .secret)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(collaboratorsCount, forKey: .collaboratorsCount)
        try container.encode(isPersonal, forKey: .isPersonal)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sharedAt = "shared_at"
        case name
        case externalId = "external_id"
        case secret
        case ownerId = "owner_id"
        case collaboratorsCount = "collaborators_count"
        case isPersonal = "is_personal"
    }
    
}
