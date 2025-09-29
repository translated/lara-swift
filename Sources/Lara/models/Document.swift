import Foundation

public enum DocumentStatus: String, Codable {
    case initialized = "initialized"    // just been created
    case analyzing = "analyzing"        // being analyzed for language detection and chars count
    case paused = "paused"              // paused after analysis, needs user confirm
    case ready = "ready"                // ready to be translated
    case translating = "translating"
    case translated = "translated"
    case error = "error"
}

public struct DocumentUploadOptions: Codable {

    public var adaptTo: [String]?

    public var glossaries: [String]?

    public var noTrace: Bool?

    public var style: TranslationStyle?

    public var password: String?

    public var extractionParams: DocumentExtractionParams?

    public init(adaptTo: [String]? = nil, glossaries: [String]? = nil, noTrace: Bool? = nil, style: TranslationStyle? = nil, password: String? = nil, extractionParams: DocumentExtractionParams? = nil) {
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.noTrace = noTrace
        self.style = style
        self.password = password
        self.extractionParams = extractionParams
    }

    private enum CodingKeys: String, CodingKey {
        case adaptTo = "adapt_to"
        case glossaries
        case noTrace = "no_trace"
        case style
        case password
    }

    public func toParams() -> [String: Any] {
        var params: [String: Any] = [:]

        if let adaptTo = adaptTo {
            params["adapt_to"] = adaptTo
        }

        if let glossaries = glossaries {
            params["glossaries"] = glossaries
        }

        if let style = style {
            params["style"] = style.rawValue
        }

        if let password = password {
            params["password"] = password
        }

        if let extractionParams = extractionParams {
            params["extraction_params"] = extractionParams.toParams()
        }

        return params
    }
}

public struct DocumentOptions: Codable {
    public var adaptTo: [String]?
    public var glossaries: [String]?
    public var noTrace: Bool?
    public var style: TranslationStyle?

    public init(adaptTo: [String]? = nil, glossaries: [String]? = nil, noTrace: Bool? = nil, style: TranslationStyle? = nil) {
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.noTrace = noTrace
        self.style = style
    }

    private enum CodingKeys: String, CodingKey {
        case adaptTo = "adapt_to"
        case glossaries
        case noTrace = "no_trace"
        case style
    }
}

public struct DocumentDownloadOptions {

    public var outputFormat: String?

    public init(outputFormat: String? = nil) {
        self.outputFormat = outputFormat
    }

    public func toParams() -> [String: Any] {
        var params: [String: Any] = [:]

        if let outputFormat = outputFormat {
            params["output_format"] = outputFormat
        }

        return params
    }
}

public struct DocumentTranslateOptions {

    public var adaptTo: [String]?

    public var glossaries: [String]?

    public var noTrace: Bool?

    public var style: TranslationStyle?

    public var outputFormat: String?

    public var password: String?

    public var extractionParams: DocumentExtractionParams?

    public init(adaptTo: [String]? = nil, glossaries: [String]? = nil, noTrace: Bool? = nil, style: TranslationStyle? = nil, outputFormat: String? = nil, password: String? = nil, extractionParams: DocumentExtractionParams? = nil) {
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.noTrace = noTrace
        self.style = style
        self.outputFormat = outputFormat
        self.password = password
        self.extractionParams = extractionParams
    }
}

public struct Document: Codable {

    public let id: String

    public let status: DocumentStatus

    public let source: String?

    public let target: String

    public let filename: String

    public let createdAt: String

    public let updatedAt: String

    public let options: DocumentOptions?

    public let translatedChars: Int?

    public let totalChars: Int?

    public let errorReason: String?

    private enum CodingKeys: String, CodingKey {
        case id, status, source, target, filename
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case options, translatedChars = "translated_chars"
        case totalChars = "total_chars"
        case errorReason = "error_reason"
    }
}

/// Internal struct for S3 upload parameters
struct S3UploadParams: Codable {
    let url: String
    let fields: [String: String]

    private enum CodingKeys: String, CodingKey {
        case url, fields
    }
}

/// Internal struct for download URL response
struct DownloadUrlResponse: Codable {
    let url: String
}

// MARK: - Extraction Parameters

public protocol DocumentExtractionParams {
    func toParams() -> [String: Any]
}

/// Extraction parameters for DOCX files
public struct DocxExtractionParams: DocumentExtractionParams {
    public var extractComments: Bool?
    public var acceptRevisions: Bool?

    public init(extractComments: Bool? = nil, acceptRevisions: Bool? = nil) {
        self.extractComments = extractComments
        self.acceptRevisions = acceptRevisions
    }

    public func toParams() -> [String: Any] {
        var params: [String: Any] = [:]

        if let extractComments = extractComments {
            params["extract_comments"] = extractComments
        }

        if let acceptRevisions = acceptRevisions {
            params["accept_revisions"] = acceptRevisions
        }

        return params
    }
}
