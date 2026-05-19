import Foundation

public struct MemoryExport: Codable, Sendable {
    public let jobId: String

    private enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
    }
}
