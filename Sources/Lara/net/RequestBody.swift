import Foundation
import CryptoKit
import UniformTypeIdentifiers

public protocol RequestBody {
    func contentType() -> String

    func contentLength() -> Int

    func md5() -> String?

    func write(to stream: OutputStream) throws
}

public class JsonRequestBody: RequestBody {
    private let bodyData: Data

    public init(params: [String: Any]) throws {
        self.bodyData = try JSONSerialization.data(withJSONObject: params)
    }

    public func contentType() -> String {
        return "application/json"
    }

    public func contentLength() -> Int {
        return bodyData.count
    }

    public func md5() -> String? {
        let digest = Insecure.MD5.hash(data: bodyData)
        return Data(digest).base64EncodedString()
    }

    public func write(to stream: OutputStream) throws {
        bodyData.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            _ = stream.write(baseAddress.assumingMemoryBound(to: UInt8.self), maxLength: bodyData.count)
        }
    }
}

enum MultipartRequestBodyError: Error {
    case encodingFailed(String)
}

public class MultipartRequestBody: RequestBody {
    private let boundary: String
    private let params: [String: String]?
    private let files: [String: MultipartFile]?

    public init(params: [String: Any]?, files: [String: MultipartFile]?) {
        self.boundary = "---------------------------LaraClient_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        self.params = params?.compactMapValues { MultipartRequestBody.serializeValue($0) }
        self.files = files
    }

    private static func serializeValue(_ value: Any) -> String? {
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: []) {
                return String(data: data, encoding: .utf8)
            }
        }
        return String(describing: value)
    }

    public func contentType() -> String {
        return "multipart/form-data; boundary=\(boundary)"
    }

    public func contentLength() -> Int {
        // This is an approximation - actual size may vary slightly due to encoding
        var totalSize = 0

        if let params = params {
            for (key, value) in params {
                totalSize += "--\(boundary)\r\n".utf8.count
                totalSize += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8.count
                totalSize += "\(value)\r\n".utf8.count
            }
        }

        if let files = files {
            for (fieldName, file) in files {
                totalSize += "--\(boundary)\r\n".utf8.count
                totalSize += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(file.filename)\"\r\n".utf8.count
                totalSize += "Content-Type: \(file.mimeType)\r\n\r\n".utf8.count
                totalSize += file.data.count
                totalSize += "\r\n".utf8.count
            }
        }

        totalSize += "--\(boundary)--\r\n".utf8.count
        return totalSize
    }

    public func md5() -> String? {
        guard let params = params else { return nil }

        var md5String = ""
        let sortedKeys = params.keys.sorted()

        for key in sortedKeys {
            if let value = params[key] {
                md5String += key
                md5String += value
            }
        }

        return md5String.data(using: .utf8)?.md5()
    }

    public func write(to stream: OutputStream) throws {
        let newLine = try stringToData("\r\n")

        // Write parameters
        if let params = params {
            for (key, value) in params {
                writeData(try stringToData("--\(boundary)\r\n"), to: stream)
                writeData(try stringToData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"), to: stream)
                writeData(try stringToData("\(value)\r\n"), to: stream)
            }
        }

        // Write files
        if let files = files {
            for (fieldName, file) in files {
                writeData(try stringToData("--\(boundary)\r\n"), to: stream)
                writeData(try stringToData("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(file.filename)\"\r\n"), to: stream)
                writeData(try stringToData("Content-Type: \(file.mimeType)\r\n\r\n"), to: stream)
                writeData(file.data, to: stream)
                writeData(newLine, to: stream)
            }
        }

        // Write closing boundary
        writeData(try stringToData("--\(boundary)--\r\n"), to: stream)
    }

    private func stringToData(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw MultipartRequestBodyError.encodingFailed("Failed to encode string: \(string)")
        }
        return data
    }

    private func writeData(_ data: Data, to stream: OutputStream) {
        data.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            _ = stream.write(baseAddress.assumingMemoryBound(to: UInt8.self), maxLength: data.count)
        }
    }
}

public struct MultipartFile {
    public let filename: String
    public let data: Data
    public let mimeType: String

    public init(filename: String, data: Data, mimeType: String? = nil) {
        self.filename = filename
        self.data = data
        self.mimeType = mimeType ?? MultipartFile.detectMimeType(for: filename)
    }

    public static func detectMimeType(for filename: String) -> String {
        let fileExtension = (filename as NSString).pathExtension.lowercased()

        // Use UniformTypeIdentifiers for automatic MIME type detection
        if #available(iOS 14.0, macOS 11.0, *) {
            if let utType = UTType(filenameExtension: fileExtension),
               let mimeType = utType.preferredMIMEType {
                return mimeType
            }
        }

        // Fallback for older systems
        let fallbackTypes: [String: String] = [
            "tmx": "application/xml",
            "xml": "application/xml",
            "gz": "application/gzip",
            "zip": "application/zip"
        ]

        return fallbackTypes[fileExtension] ?? "application/octet-stream"
    }



}

// MARK: - MD5 Extension
extension Data {
    func md5() -> String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
