import Foundation

public struct ImageTextResult: Codable {
    public let sourceLanguage: String
    public let adaptedTo: [String]?
    public let glossaries: [String]?
    public let paragraphs: [ImageParagraph]

    public init(sourceLanguage: String,
                adaptedTo: [String]? = nil,
                glossaries: [String]? = nil,
                paragraphs: [ImageParagraph]) {
        self.sourceLanguage = sourceLanguage
        self.adaptedTo = adaptedTo
        self.glossaries = glossaries
        self.paragraphs = paragraphs
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sourceLanguage = try container.decode(String.self, forKey: .sourceLanguage)
        adaptedTo = try container.decodeIfPresent([String].self, forKey: .adaptedTo)
        glossaries = try container.decodeIfPresent([String].self, forKey: .glossaries)
        paragraphs = try container.decode([ImageParagraph].self, forKey: .paragraphs)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sourceLanguage, forKey: .sourceLanguage)
        try container.encodeIfPresent(adaptedTo, forKey: .adaptedTo)
        try container.encodeIfPresent(glossaries, forKey: .glossaries)
        try container.encode(paragraphs, forKey: .paragraphs)
    }

    private enum CodingKeys: String, CodingKey {
        case sourceLanguage = "source_language"
        case adaptedTo = "adapted_to"
        case glossaries
        case paragraphs
    }
}