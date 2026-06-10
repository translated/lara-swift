import Foundation

public struct GlossaryExport: Codable, Sendable {
    public let jobId: String

    private enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
    }
}
