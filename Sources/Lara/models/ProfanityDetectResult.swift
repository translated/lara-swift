import Foundation

public struct DetectedProfanity: Codable {
    public let text: String
    public let startCharIndex: Int
    public let endCharIndex: Int
    public let score: Double

    private enum CodingKeys: String, CodingKey {
        case text
        case startCharIndex = "start_char_index"
        case endCharIndex = "end_char_index"
        case score
    }
}

public struct ProfanityDetectResult: Codable {
    public let maskedText: String
    public let profanities: [DetectedProfanity]

    private enum CodingKeys: String, CodingKey {
        case maskedText = "masked_text"
        case profanities
    }
}
