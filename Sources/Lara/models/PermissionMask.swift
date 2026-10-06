import Foundation

/// Resource permissions in read, write, export, share order; a dash means absent.
public struct PermissionMask: RawRepresentable, Codable, Hashable, Sendable {
    public static let read = PermissionMask(rawValue: "r---")
    public static let readWrite = PermissionMask(rawValue: "rw--")
    public static let readExport = PermissionMask(rawValue: "r-e-")
    public static let readShare = PermissionMask(rawValue: "r--s")
    public static let readWriteExport = PermissionMask(rawValue: "rwe-")
    public static let readWriteShare = PermissionMask(rawValue: "rw-s")
    public static let readExportShare = PermissionMask(rawValue: "r-es")
    public static let readWriteExportShare = PermissionMask(rawValue: "rwes")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

