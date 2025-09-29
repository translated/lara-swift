public class NGGlossaryMatch: Codable {
    let glossary: String
    let language: [String]
    let term: String
    let translation: String
    
    public init(glossary: String, language: [String], term: String, translation: String) {
        self.glossary = glossary
        self.language = language
        self.term = term
        self.translation = translation
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let glossary = try container.decode(String.self, forKey: .glossary)
        let language = try container.decode([String].self, forKey: .language)
        let term = try container.decode(String.self, forKey: .term)
        let translation = try container.decode(String.self, forKey: .translation)
        
        self.init(glossary: glossary, language: language, term: term, translation: translation)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(glossary, forKey: .glossary)
        try container.encode(language, forKey: .language)
        try container.encode(term, forKey: .term)
        try container.encode(translation, forKey: .translation)
    }
    
    private enum CodingKeys: String, CodingKey {
        case glossary
        case language
        case term
        case translation
    }
}
