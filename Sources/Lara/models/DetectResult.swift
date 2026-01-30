import Foundation

public struct DetectPrediction: Codable {
    public let language: String
    public let confidence: Double

    private enum CodingKeys: String, CodingKey {
        case language
        case confidence
    }
}

public struct DetectResult: Codable {
    public let language: String
    public let contentType: String
    public let predictions: [DetectPrediction]

    private enum CodingKeys: String, CodingKey {
        case language
        case contentType = "content_type"
        case predictions
    }
}
