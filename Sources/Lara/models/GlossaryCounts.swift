import Foundation

public class GlossaryCounts: Codable {
    public let unidirectional: [String: Int]?
    public let multidirectional: Int?

    init(unidirectional: [String: Int]?, multidirectional: Int?) {
        self.unidirectional = unidirectional
        self.multidirectional = multidirectional
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let unidirectional = try container.decodeIfPresent([String: Int].self, forKey: .unidirectional)
        let multidirectional = try container.decodeIfPresent(Int.self, forKey: .multidirectional)

        self.init(unidirectional: unidirectional, multidirectional: multidirectional)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(unidirectional, forKey: .unidirectional)
        try container.encodeIfPresent(multidirectional, forKey: .multidirectional)
    }

    private enum CodingKeys: String, CodingKey {
        case unidirectional
        case multidirectional
    }
}
