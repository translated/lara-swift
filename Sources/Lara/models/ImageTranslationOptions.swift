import Foundation

public struct ImageTranslationOptions {
    public var adaptTo: [String]?
    public var glossaries: [String]?
    public var style: TranslationStyle?
    public var textRemoval: ImageTextRemoval?
    public var noTrace: Bool?

    public init(adaptTo: [String]? = nil,
                glossaries: [String]? = nil,
                style: TranslationStyle? = nil,
                textRemoval: ImageTextRemoval? = nil,
                noTrace: Bool? = nil) {
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.style = style
        self.textRemoval = textRemoval
        self.noTrace = noTrace
    }

    public func toParams() -> [String: Any] {
        var params = [String: Any]()

        if let adaptTo = self.adaptTo {
            params["adapt_to"] = String(data: try! JSONSerialization.data(withJSONObject: adaptTo, options: []), encoding: .utf8)!
        }
        if let glossaries = self.glossaries {
            params["glossaries"] = String(data: try! JSONSerialization.data(withJSONObject: glossaries, options: []), encoding: .utf8)!
        }
        if let style = self.style {
            params["style"] = style.rawValue
        }
        if let textRemoval = self.textRemoval {
            params["text_removal"] = textRemoval.rawValue
        }

        return params
    }
}