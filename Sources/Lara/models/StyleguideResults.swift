import Foundation

public class StyleguideChange: Codable {
    public let id: String?
    public let originalTranslation: String
    public let refinedTranslation: String
    public let explanation: String

    init(id: String? = nil, originalTranslation: String, refinedTranslation: String, explanation: String) {
        self.id = id
        self.originalTranslation = originalTranslation
        self.refinedTranslation = refinedTranslation
        self.explanation = explanation
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case originalTranslation = "original_translation"
        case refinedTranslation = "refined_translation"
        case explanation
    }
}

public class StyleguideResults: Codable {
    public let originalTranslation: TranslatedValue
    public let changes: [StyleguideChange]

    init(originalTranslation: TranslatedValue, changes: [StyleguideChange]) {
        self.originalTranslation = originalTranslation
        self.changes = changes
    }

    private enum CodingKeys: String, CodingKey {
        case originalTranslation = "original_translation"
        case changes
    }
}
