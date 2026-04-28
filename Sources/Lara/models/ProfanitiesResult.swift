import Foundation

/// Wraps profanity detection results for both target and (optionally) source text.
/// Returned in `TextResult.profanities` when `profanitiesDetect` is set.
public class ProfanitiesResult: Codable {
    /// Profanity detection results for the translated (target) text.
    public let target: ProfanitiesValue?
    /// Profanity detection results for the source text.
    /// Present only when `profanitiesDetect = .sourceTarget` was requested.
    public let source: ProfanitiesValue?

    public init(target: ProfanitiesValue?, source: ProfanitiesValue?) {
        self.target = target
        self.source = source
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.target = try container.decodeIfPresent(ProfanitiesValue.self, forKey: .target)
        self.source = try container.decodeIfPresent(ProfanitiesValue.self, forKey: .source)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(target, forKey: .target)
        try container.encodeIfPresent(source, forKey: .source)
    }

    private enum CodingKeys: String, CodingKey {
        case target
        case source
    }
}
