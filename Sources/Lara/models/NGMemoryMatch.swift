public class NGMemoryMatch: Codable {
    public let memory: String
    let tuid: String
    let language: [String]
    let sentence: String
    let translation: String
    let score: Double
    
    public init(memory: String, tuid: String, language: [String], sentence: String, translation: String, score: Double) {
        self.memory = memory
        self.tuid = tuid
        self.language = language
        self.sentence = sentence
        self.translation = translation
        self.score = score
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let memory = try container.decode(String.self, forKey: .memory)
        let tuid = try container.decode(String.self, forKey: .tuid)
        let language = try container.decode([String].self, forKey: .language)
        let sentence = try container.decode(String.self, forKey: .sentence)
        let translation = try container.decode(String.self, forKey: .translation)
        let score = try container.decode(Double.self, forKey: .score)
        
        self.init(memory: memory, tuid: tuid, language: language, sentence: sentence, translation: translation, score: score)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(memory, forKey: .memory)
        try container.encode(tuid, forKey: .tuid)
        try container.encode(language, forKey: .language)
        try container.encode(sentence, forKey: .sentence)
        try container.encode(translation, forKey: .translation)
        try container.encode(score, forKey: .score)
    }
    
    private enum CodingKeys: String, CodingKey {
        case memory
        case tuid
        case language
        case sentence
        case translation
        case score
    }
}
