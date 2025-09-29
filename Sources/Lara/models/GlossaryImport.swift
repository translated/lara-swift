import Foundation

public final class GlossaryImport: Codable, Sendable {
    public let id: String
    public let begin: Int
    public let end: Int
    public let channel: Int
    public let size: Int
    public let progress: Double

    init(id: String, begin: Int, end: Int, channel: Int, size: Int, progress: Double) {
        self.id = id
        self.begin = begin
        self.end = end
        self.channel = channel
        self.size = size
        self.progress = progress
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let begin = try container.decode(Int.self, forKey: .begin)
        let end = try container.decode(Int.self, forKey: .end)
        let channel = try container.decode(Int.self, forKey: .channel)
        let size = try container.decode(Int.self, forKey: .size)
        let progress = try container.decode(Double.self, forKey: .progress)

        self.init(id: id, begin: begin, end: end, channel: channel, size: size, progress: progress)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(begin, forKey: .begin)
        try container.encode(end, forKey: .end)
        try container.encode(channel, forKey: .channel)
        try container.encode(size, forKey: .size)
        try container.encode(progress, forKey: .progress)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case begin
        case end
        case channel
        case size
        case progress
    }
}
