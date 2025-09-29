struct GetTranslationError: Error {
    let message: String
}

public class TranslatedValue: Codable {
    let translation: String?
    let translations: [String]?
    let translationBlocks: [TextBlock]?
    
    init(translation: String) {
        self.translation = translation
        self.translations = nil
        self.translationBlocks = nil
    }
    
    init(translations: [String]) {
        self.translation = nil
        self.translations = translations
        self.translationBlocks = nil
    }
    
    init(translationBlocks: [TextBlock]) {
        self.translation = nil
        self.translations = nil
        self.translationBlocks = translationBlocks
    }
    
    // Decodifica custom
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let single = try? container.decode(String.self) {
            self.translation = single
            self.translations = nil
            self.translationBlocks = nil
        } else if let multiple = try? container.decode([String].self) {
            self.translation = nil
            self.translations = multiple
            self.translationBlocks = nil
        } else if let blocks = try? container.decode([TextBlock].self) {
            self.translation = nil
            self.translations = nil
            self.translationBlocks = blocks
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid type for translation")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let translation = translation {
            try container.encode(translation)
        } else if let translations = translations {
            try container.encode(translations)
        } else if let blocks = translationBlocks {
            try container.encode(blocks)
        }
    }
    
    
    public func getTranslation() throws -> String? {
        if let translation = translation {
            return translation
        }
        
        if let translations = translations, !translations.isEmpty {
            if translations.count != 1 {
                throw GetTranslationError(message: "Cannot get translation from multiple elements (\(translations.count))")
            }
            return translations[0]
        }
        
        if let translationBlocks = translationBlocks, !translationBlocks.isEmpty {
            if translationBlocks.count != 1 {
                throw GetTranslationError(message: "Cannot get translation from multiple elements (\(translationBlocks.count))")
            }
            return translationBlocks[0].text
        }
        
        return nil
    }
    
    public func getTranslations() -> [String]? {
        if let translations = translations, !translations.isEmpty {
            return translations
        }
        
        if let translation = translation {
            return [translation]
        }
        
        if let translationBlocks = translationBlocks, !translationBlocks.isEmpty {
            return translationBlocks.map { $0.text }
        }
        
        return nil
    }
    
    public func getTranslationBlocks() -> [TextBlock]? {
        if let translationBlocks = translationBlocks, !translationBlocks.isEmpty {
            return translationBlocks
        }
        
        if let translation = translation {
            return [TextBlock(text: translation)]
        }
        
        if let translations = translations, !translations.isEmpty {
            return translations.map { TextBlock(text: $0) }
        }
        
        return nil
    }
}
