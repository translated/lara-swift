import Foundation

public class TextResult: Codable {
    public let contentType: String
    public let sourceLanguage: String
    public let translation: TranslatedValue
    public let adaptedTo: [String]
    public let glossaries: [String]?
    public let adaptedToMatches: AdaptedToMatches?
    public let glossariesMatches: GlossariesMatches?
    public let profanities: ProfanitiesValue?
    public let styleguideResults: StyleguideResults?
    
    public init(contentType: String, sourceLanguage: String, translation: TranslatedValue, adaptedTo: [String], glossaries: [String]?, adaptedToMatches: AdaptedToMatches?, glossariesMatches: GlossariesMatches?, profanities: ProfanitiesValue? = nil, styleguideResults: StyleguideResults? = nil) {
        self.contentType = contentType
        self.sourceLanguage = sourceLanguage
        self.translation = translation
        self.adaptedTo = adaptedTo
        self.glossaries = glossaries
        self.adaptedToMatches = adaptedToMatches
        self.glossariesMatches = glossariesMatches
        self.profanities = profanities
        self.styleguideResults = styleguideResults
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contentType = try container.decode(String.self, forKey: .contentType)
        let sourceLanguage = try container.decode(String.self, forKey: .sourceLanguage)
        let translation = try container.decode(TranslatedValue.self, forKey: .translation)
        let adaptedTo = try container.decodeIfPresent([String].self, forKey: .adaptedTo) ?? []
        let glossaries = try container.decodeIfPresent([String].self, forKey: .glossaries)
        let adaptedToMatches = try container.decodeIfPresent(AdaptedToMatches.self, forKey: .adaptedToMatches)
        let glossariesMatches = try container.decodeIfPresent(GlossariesMatches.self, forKey: .glossariesMatches)
        let profanities = try container.decodeIfPresent(ProfanitiesValue.self, forKey: .profanities)
        let styleguideResults = try container.decodeIfPresent(StyleguideResults.self, forKey: .styleguideResults)

        self.init(contentType: contentType, sourceLanguage: sourceLanguage, translation: translation, adaptedTo: adaptedTo, glossaries: glossaries, adaptedToMatches: adaptedToMatches, glossariesMatches: glossariesMatches, profanities: profanities, styleguideResults: styleguideResults)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(sourceLanguage, forKey: .sourceLanguage)
        try container.encode(translation, forKey: .translation)
        try container.encode(adaptedTo, forKey: .adaptedTo)
        try container.encodeIfPresent(glossaries, forKey: .glossaries)
        try container.encodeIfPresent(adaptedToMatches, forKey: .adaptedToMatches)
        try container.encodeIfPresent(glossariesMatches, forKey: .glossariesMatches)
        try container.encodeIfPresent(profanities, forKey: .profanities)
        try container.encodeIfPresent(styleguideResults, forKey: .styleguideResults)
    }

    private enum CodingKeys: String, CodingKey {
        case contentType = "content_type"
        case sourceLanguage = "source_language"
        case translation
        case adaptedTo = "adapted_to"
        case glossaries
        case adaptedToMatches = "adapted_to_matches"
        case glossariesMatches = "glossaries_matches"
        case profanities
        case styleguideResults = "styleguide_results"
    }
}
