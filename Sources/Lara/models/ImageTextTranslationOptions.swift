import Foundation

public struct ImageTextTranslationOptions {
    public var adaptTo: [String]?
    public var glossaries: [String]?
    public var verbose: Bool?
    public var style: TranslationStyle?
    public var noTrace: Bool?
    /// When true, includes complete geometry and styling on every returned paragraph,
    /// independently of verbose.
    public var includeLayout: Bool?

    public init(adaptTo: [String]? = nil,
                glossaries: [String]? = nil,
                verbose: Bool? = nil,
                style: TranslationStyle? = nil,
                noTrace: Bool? = nil,
                includeLayout: Bool? = nil) {
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.verbose = verbose
        self.style = style
        self.noTrace = noTrace
        self.includeLayout = includeLayout
    }

    public func toParams() -> [String: Any] {
        var params = [String: Any]()

        if let adaptTo = self.adaptTo {
            params["adapt_to"] = String(data: try! JSONSerialization.data(withJSONObject: adaptTo, options: []), encoding: .utf8)!
        }
        if let glossaries = self.glossaries {
            params["glossaries"] = String(data: try! JSONSerialization.data(withJSONObject: glossaries, options: []), encoding: .utf8)!
        }
        if let verbose = self.verbose {
            params["verbose"] = verbose
        }
        if let includeLayout = self.includeLayout {
            params["include_layout"] = includeLayout
        }
        if let style = self.style {
            params["style"] = style.rawValue
        }

        return params
    }
}
