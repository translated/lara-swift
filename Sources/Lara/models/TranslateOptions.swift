import Foundation

public enum Priority: String {
    case normal
    case background
}

public enum UseCache: String {
    case yes
    case no
    case overwrite
}

public enum TranslationStyle: String, Codable {
    case faithful
    case fluid
    case creative
}

public enum ProfanityFilter: String {
    case detect
    case avoid
    case hide
}

public enum ContentType: String {
    case text = "text/plain"
    case html = "text/html"
    case xml = "text/xml"
    case xliff = "application/xliff+xml"
}

public enum TranslationMetadata {
    case string(String)
    case object([String: Any])
}

public struct TranslateOptions {
    public var sourceHint: String?
    public var adaptTo: [String]?
    public var glossaries: [String]?
    public var instructions: [String]?
    public var contentType: String?
    public var multiline: Bool?
    public var timeoutMs: Int64?
    public var priority: Priority?
    public var useCache: UseCache?
    public var cacheTTL: Int?
    public var noTrace: Bool?
    public var verbose: Bool?
    public var headers: [String: String]?
    public var style: TranslationStyle?
    public var reasoning: Bool?
    public var metadata: TranslationMetadata?
    public var profanityFilter: ProfanityFilter?

    public init(sourceHint: String? = nil,
                adaptTo: [String]? = nil,
                glossaries: [String]? = nil,
                instructions: [String]? = nil,
                contentType: String? = nil,
                multiline: Bool? = nil,
                timeoutMs: Int64? = nil,
                priority: Priority? = nil,
                useCache: UseCache? = nil,
                cacheTTL: Int? = nil,
                noTrace: Bool? = nil,
                verbose: Bool? = nil,
                headers: [String: String]? = nil,
                style: TranslationStyle? = nil,
                reasoning: Bool? = nil,
                metadata: TranslationMetadata? = nil,
                profanityFilter: ProfanityFilter? = nil) {
        self.sourceHint = sourceHint
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.instructions = instructions
        self.contentType = contentType
        self.multiline = multiline
        self.timeoutMs = timeoutMs
        self.priority = priority
        self.useCache = useCache
        self.cacheTTL = cacheTTL
        self.noTrace = noTrace
        self.verbose = verbose
        self.headers = headers
        self.style = style
        self.reasoning = reasoning
        self.metadata = metadata
        self.profanityFilter = profanityFilter
    }

    public func toParams() -> [String: Any] {
        var params = [String: Any]()

        if let sourceHint = self.sourceHint {
            params["source_hint"] = sourceHint
        }
        if let adaptTo = self.adaptTo {
            params["adapt_to"] = adaptTo
        }
        if let glossaries = self.glossaries {
            params["glossaries"] = glossaries
        }
        if let instructions = self.instructions {
            params["instructions"] = instructions
        }
        if let contentType = self.contentType {
            params["content_type"] = contentType
        }
        if let multiline = self.multiline {
            params["multiline"] = multiline
        }
        if let timeoutMs = self.timeoutMs {
            params["timeout"] = timeoutMs
        }
        if let priority = self.priority {
            params["priority"] = priority.rawValue
        }
        if let useCache = self.useCache {
            params["use_cache"] = useCache.rawValue
        }
        if let cacheTTL = self.cacheTTL {
            params["cache_ttl"] = cacheTTL
        }
        if let verbose = self.verbose {
            params["verbose"] = verbose
        }
        if let style = self.style {
            params["style"] = style.rawValue
        }
        if let reasoning = self.reasoning {
            params["reasoning"] = reasoning
        }
        if let metadata = self.metadata {
            switch metadata {
            case .string(let value):
                params["metadata"] = value
            case .object(let value):
                params["metadata"] = value
            }
        }
        if let profanityFilter = self.profanityFilter {
            params["profanity_filter"] = profanityFilter.rawValue
        }

        return params
    }
}
