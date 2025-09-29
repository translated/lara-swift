import Foundation

public class TextBlock: Codable {
    public var text: String
    public var translatable: Bool

    public init(text: String, translatable: Bool = true) {
        self.text = text
        self.translatable = translatable
    }

    /// Returns the dictionary representation used for API calls
    public var apiRepresentation: [String: Any] {
        ["text": text, "translatable": translatable]
    }
}
