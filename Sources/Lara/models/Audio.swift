import Foundation

public enum AudioStatus: String, Codable {
    case initialized = "initialized"    // just been created
    case analyzing = "analyzing"        // being analyzed for language detection and chars count
    case paused = "paused"              // paused after analysis, needs user confirm
    case ready = "ready"                // ready to be translated
    case translating = "translating"
    case translated = "translated"
    case error = "error"
}

public struct AudioOptions: Codable {

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

public struct AudioUploadOptions {

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

        return params
    }
}


public struct Audio: Codable {

    public let id: String

    public let status: AudioStatus

    public let source: String?

    public let target: String

    public let filename: String

    public let createdAt: String

    public let updatedAt: String

    public let options: AudioOptions?

    public let translatedSeconds: Int?

    public let totalSeconds: Int?

    public let errorReason: String?

    private enum CodingKeys: String, CodingKey {
        case id, status, source, target, filename
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case options, translatedSeconds = "translated_seconds"
        case totalSeconds = "total_seconds"
        case errorReason = "error_reason"
    }
}

/// Internal struct for S3 upload parameters
struct AudioS3UploadParams: Codable {
    let url: String
    let fields: [String: String]

    private enum CodingKeys: String, CodingKey {
        case url, fields
    }
}

/// Internal struct for download URL response
struct AudioDownloadUrlResponse: Codable {
    let url: String
}
