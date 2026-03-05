import Foundation

public struct ImageParagraph: Codable {
    public let text: String
    public let translation: String
    public let adaptedToMatches: [NGMemoryMatch]?
    public let glossariesMatches: [NGGlossaryMatch]?

    public init(text: String,
                translation: String,
                adaptedToMatches: [NGMemoryMatch]? = nil,
                glossariesMatches: [NGGlossaryMatch]? = nil) {
        self.text = text
        self.translation = translation
        self.adaptedToMatches = adaptedToMatches
        self.glossariesMatches = glossariesMatches
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        translation = try container.decode(String.self, forKey: .translation)
        adaptedToMatches = try container.decodeIfPresent([NGMemoryMatch].self, forKey: .adaptedToMatches)
        glossariesMatches = try container.decodeIfPresent([NGGlossaryMatch].self, forKey: .glossariesMatches)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(translation, forKey: .translation)
        try container.encodeIfPresent(adaptedToMatches, forKey: .adaptedToMatches)
        try container.encodeIfPresent(glossariesMatches, forKey: .glossariesMatches)
    }

    private enum CodingKeys: String, CodingKey {
        case text
        case translation
        case adaptedToMatches = "adapted_to_matches"
        case glossariesMatches = "glossaries_matches"
    }
}