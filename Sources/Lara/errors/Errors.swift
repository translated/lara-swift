import Foundation

public protocol LaraError: Error, CustomStringConvertible {}

public struct TimeoutError: LaraError {
    public let description: String
    public init(_ message: String = "Operation timed out") { self.description = message }
}

public struct LaraApiConnectionError: LaraError {
    public let description: String
    public init(_ message: String) { self.description = message }
}

public struct S3Error: LaraError {
    public let description: String
    public init(_ message: String) { self.description = message }
}

public struct LaraValidationError: LaraError {
    public let description: String
    public init(_ message: String) { self.description = message }
}

public struct LaraApiError: LaraError {
    public let statusCode: Int
    public let type: String
    public let description: String

    public init(statusCode: Int, type: String, message: String) {
        self.statusCode = statusCode
        self.type = type
        self.description = message
    }
}



