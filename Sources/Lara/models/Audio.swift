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

public enum VoiceGender: String, Codable {
    case male = "male"
    case female = "female"
}

public struct AudioOptions: Codable {

    public var adaptTo: [String]?

    public var glossaries: [String]?

    public var noTrace: Bool?

    public var style: TranslationStyle?

    public var voiceCloning: Bool?

    public var voiceGender: VoiceGender?

    public init(adaptTo: [String]? = nil, glossaries: [String]? = nil, noTrace: Bool? = nil, style: TranslationStyle? = nil, voiceCloning: Bool? = nil, voiceGender: VoiceGender? = nil) {
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.noTrace = noTrace
        self.style = style
        self.voiceCloning = voiceCloning
        self.voiceGender = voiceGender
    }

    private enum CodingKeys: String, CodingKey {
        case adaptTo = "adapt_to"
        case glossaries
        case noTrace = "no_trace"
        case style
        case voiceCloning = "voice_cloning"
        case voiceGender = "voice_gender"
    }
}

public struct AudioUploadOptions {

    public var adaptTo: [String]?

    public var glossaries: [String]?

    public var noTrace: Bool?

    public var style: TranslationStyle?

    public var voiceCloning: Bool?

    public var voiceGender: VoiceGender?

    public init(adaptTo: [String]? = nil, glossaries: [String]? = nil, noTrace: Bool? = nil, style: TranslationStyle? = nil, voiceCloning: Bool? = nil, voiceGender: VoiceGender? = nil) {
        self.adaptTo = adaptTo
        self.glossaries = glossaries
        self.noTrace = noTrace
        self.style = style
        self.voiceCloning = voiceCloning
        self.voiceGender = voiceGender
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

        if let voiceCloning = voiceCloning {
            params["voice_cloning"] = voiceCloning
        }

        if let voiceGender = voiceGender {
            params["voice_gender"] = voiceGender.rawValue
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

// MARK: - Transcript Types

/// Options for audio transcript upload
public struct AudioTranscriptUploadOptions {

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

/// A single segment in the audio transcript
public struct AudioTextSegment: Codable {
    public let id: Int
    public let start: Double
    public let end: Double
    public let text: String
    public let translation: String

    public init(id: Int = 0, start: Double = 0, end: Double = 0, text: String = "", translation: String = "") {
        self.id = id
        self.start = start
        self.end = end
        self.text = text
        self.translation = translation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        start = try container.decodeIfPresent(Double.self, forKey: .start) ?? 0
        end = try container.decodeIfPresent(Double.self, forKey: .end) ?? 0
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        translation = try container.decodeIfPresent(String.self, forKey: .translation) ?? ""
    }
}

/// The result of an audio transcript translation
public struct AudioTextResult: Codable {
    public let id: String
    public let source: String
    public let target: String
    public let filename: String
    public let duration: Double
    public let text: String
    public let translation: String
    public let segments: [AudioTextSegment]

    public init(
        id: String = "",
        source: String = "",
        target: String = "",
        filename: String = "",
        duration: Double = 0,
        text: String = "",
        translation: String = "",
        segments: [AudioTextSegment] = []
    ) {
        self.id = id
        self.source = source
        self.target = target
        self.filename = filename
        self.duration = duration
        self.text = text
        self.translation = translation
        self.segments = segments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        source = try container.decodeIfPresent(String.self, forKey: .source) ?? ""
        target = try container.decodeIfPresent(String.self, forKey: .target) ?? ""
        filename = try container.decodeIfPresent(String.self, forKey: .filename) ?? ""
        duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 0
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        translation = try container.decodeIfPresent(String.self, forKey: .translation) ?? ""
        segments = try container.decodeIfPresent([AudioTextSegment].self, forKey: .segments) ?? []
    }
}
