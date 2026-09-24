import Foundation

public struct ImageParagraph: Codable {
    public let text: String
    public let translation: String
    public let adaptedToMatches: [NGMemoryMatch]?
    public let glossariesMatches: [NGGlossaryMatch]?
    /// Layout is populated on every paragraph when includeLayout is true.
    public let bbox: ImageBBox?
    public let linesBboxes: [ImageBBox]?
    public let textInfo: ImageTextInfo?
    /// Text alignment: left, center, or right.
    public let alignment: String?

    public init(text: String,
                translation: String,
                adaptedToMatches: [NGMemoryMatch]? = nil,
                glossariesMatches: [NGGlossaryMatch]? = nil,
                bbox: ImageBBox? = nil,
                linesBboxes: [ImageBBox]? = nil,
                textInfo: ImageTextInfo? = nil,
                alignment: String? = nil) {
        self.text = text
        self.translation = translation
        self.adaptedToMatches = adaptedToMatches
        self.glossariesMatches = glossariesMatches
        self.bbox = bbox
        self.linesBboxes = linesBboxes
        self.textInfo = textInfo
        self.alignment = alignment
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        translation = try container.decode(String.self, forKey: .translation)
        adaptedToMatches = try container.decodeIfPresent([NGMemoryMatch].self, forKey: .adaptedToMatches)
        glossariesMatches = try container.decodeIfPresent([NGGlossaryMatch].self, forKey: .glossariesMatches)
        bbox = try container.decodeIfPresent(ImageBBox.self, forKey: .bbox)
        linesBboxes = try container.decodeIfPresent([ImageBBox].self, forKey: .linesBboxes)
        textInfo = try container.decodeIfPresent(ImageTextInfo.self, forKey: .textInfo)
        alignment = try container.decodeIfPresent(String.self, forKey: .alignment)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(translation, forKey: .translation)
        try container.encodeIfPresent(adaptedToMatches, forKey: .adaptedToMatches)
        try container.encodeIfPresent(glossariesMatches, forKey: .glossariesMatches)
        try container.encodeIfPresent(bbox, forKey: .bbox)
        try container.encodeIfPresent(linesBboxes, forKey: .linesBboxes)
        try container.encodeIfPresent(textInfo, forKey: .textInfo)
        try container.encodeIfPresent(alignment, forKey: .alignment)
    }

    private enum CodingKeys: String, CodingKey {
        case text
        case translation
        case adaptedToMatches = "adapted_to_matches"
        case glossariesMatches = "glossaries_matches"
        case bbox
        case linesBboxes = "lines_bboxes"
        case textInfo = "text_info"
        case alignment
    }
}
