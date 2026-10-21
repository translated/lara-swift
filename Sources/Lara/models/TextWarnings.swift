import Foundation

public struct IntelligenceError: Codable {
    public let statusCode: Int
    public let message: String

    private enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case message
    }
}

public struct IntelligenceFailure: Codable {
    public let applied: Bool
    public let error: IntelligenceError
}

public enum ReferenceRetrievalApplied: Codable, Equatable {
    case notApplied
    case partial

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self), !value {
            self = .notApplied
        } else if let value = try? container.decode(String.self), value == "partial" {
            self = .partial
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected false or partial")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .notApplied: try container.encode(false)
        case .partial: try container.encode("partial")
        }
    }
}

public struct ReferenceRetrievalFailure: Codable {
    public let applied: ReferenceRetrievalApplied
    public let error: IntelligenceError
}

public struct ReasoningWarning: Codable {
    public let code: String
    public let message: String
}

public struct ReasoningFeedback: Codable {
    public let applied: Bool
    public let error: IntelligenceError?
    public let warnings: [ReasoningWarning]

    private enum CodingKeys: String, CodingKey {
        case applied, error, warnings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        applied = try container.decode(Bool.self, forKey: .applied)
        error = try container.decodeIfPresent(IntelligenceError.self, forKey: .error)
        warnings = try container.decodeIfPresent([ReasoningWarning].self, forKey: .warnings) ?? []
    }
}

public struct TextWarnings: Codable {
    public let reasoning: ReasoningFeedback?
    public let references: ReferenceRetrievalFailure?
    public let prosa: IntelligenceFailure?
}
