import Foundation

public struct ApiResponse<T: Codable>: Codable {
    public let status: Int?
    public let content: T
}



