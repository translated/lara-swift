import Foundation
import CommonCrypto

public class Client {

    private let baseUrl: URL
    private let accessKeyId: String
    private let accessKeySecret: String
    private var extraHeaders: [String: String] = [:]

    public var connectionTimeout: TimeInterval
    public var readTimeout: TimeInterval

    private let jsonDecoder: JSONDecoder = APIJSONDecoder.decoder()

    // MARK: - Init
    public init(credentials: Credentials, options: ClientOptions = ClientOptions()) {
        self.accessKeyId = credentials.accessKeyId
        self.accessKeySecret = credentials.accessKeySecret

        self.baseUrl = options.serverUrl
        self.connectionTimeout = options.connectionTimeout
        self.readTimeout = options.readTimeout
    }

    // MARK: - Extra headers
    public func setExtraHeader(name: String, value: String) {
        extraHeaders[name] = value
    }

    // MARK: - HTTP Methods
    public func get(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        try await request(method: "GET", path: path, params: params, files: nil, headers: headers)
    }

    public func post(path: String, params: [String: Any]? = nil, files: [String: Data]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        let multipartFiles = files?.mapValues { data in MultipartFile(filename: UUID().uuidString, data: data) }
        return try await request(method: "POST", path: path, params: params, files: multipartFiles, headers: headers)
    }

    public func delete(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        try await request(method: "DELETE", path: path, params: params, files: nil, headers: headers)
    }

    public func put(path: String, params: [String: Any]? = nil, files: [String: Data]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        let multipartFiles = files?.mapValues { data in MultipartFile(filename: UUID().uuidString, data: data) }
        return try await request(method: "PUT", path: path, params: params, files: multipartFiles, headers: headers)
    }


    // MARK: - Core request
    private func request(method: String, path: String, params: [String: Any]?, files: [String: MultipartFile]?, headers: [String: String]?) async throws -> ClientResponse {
        let normalizedPath = normalize(path: path)
        let fullUrl = baseUrl.appendingPathComponent(normalizedPath)

        let requestBody: RequestBody? = try createRequestBody(params: params, files: files)

        // Create URLRequest
        var urlRequest = URLRequest(url: fullUrl, timeoutInterval: connectionTimeout)
        urlRequest.httpMethod = "POST"
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData

        urlRequest.setValue(method, forHTTPHeaderField: "X-HTTP-Method-Override")

        var contentTypeForSigning = ""
        if let body = requestBody {
            urlRequest.setValue(body.contentType(), forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(body.contentLength())", forHTTPHeaderField: "Content-Length")

            if let md5 = body.md5() {
                urlRequest.setValue(md5, forHTTPHeaderField: "Content-MD5")
            }

            let bodyData = try createBodyData(from: body)
            urlRequest.httpBody = bodyData
            contentTypeForSigning = body.contentType().components(separatedBy: ";").first?.trimmingCharacters(in: .whitespaces) ?? ""
        }

        // Standard headers
        let dateString = httpDate()
        urlRequest.setValue(dateString, forHTTPHeaderField: "Date")
        urlRequest.setValue("lara-swift", forHTTPHeaderField: "X-Lara-SDK-Name")
        if let version = Version.get() {
            urlRequest.setValue(version, forHTTPHeaderField: "X-Lara-SDK-Version")
        }

        // Extra headers
        extraHeaders.forEach { key, value in urlRequest.setValue(value, forHTTPHeaderField: key) }
        headers?.forEach { key, value in urlRequest.setValue(value, forHTTPHeaderField: key) }

        // Authorization
        let signature = sign(method: method, path: normalizedPath, date: dateString, contentType: contentTypeForSigning, md5: urlRequest.value(forHTTPHeaderField: "Content-MD5"))
        urlRequest.setValue("Lara \(accessKeyId):\(signature)", forHTTPHeaderField: "Authorization")

        return try await executeRequest(urlRequest)
    }

    // MARK: - Helper Methods
    private func createRequestBody(params: [String: Any]?, files: [String: MultipartFile]?) throws -> RequestBody? {
        if let files = files, !files.isEmpty {
            return MultipartRequestBody(params: params, files: files)
        } else if let params = params, !params.isEmpty {
            return try JsonRequestBody(params: params)
        } else {
            return nil
        }
    }

    private func createBodyData(from requestBody: RequestBody) throws -> Data {
        let outputStream = OutputStream.toMemory()
        outputStream.open()

        defer {
            outputStream.close()
        }

        try requestBody.write(to: outputStream)

        guard let data = outputStream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            throw LaraApiConnectionError("Failed to create request body data")
        }

        return data
    }

    private func executeRequest(_ request: URLRequest) async throws -> ClientResponse {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LaraApiConnectionError("Failed to get response")
        }

        return ClientResponse(data: data, httpResponse: httpResponse, decoder: self.jsonDecoder)
    }

    private func normalize(path: String) -> String {
        path.hasPrefix("/") ? path : "/" + path
    }

    private func httpDate() -> String {
        struct Static {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                formatter.locale = Locale(identifier: "en_US")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                return formatter
            }()
        }
        return Static.formatter.string(from: Date())
    }

    private func sign(method: String, path: String, date: String, contentType: String, md5: String?) -> String {
        let challenge: String
        if let md5 = md5 {
            challenge = "\(method)\n\(path)\n\(md5)\n\(contentType)\n\(date)"
        } else {
            challenge = "\(method)\n\(path)\n\n\(contentType)\n\(date)"
        }
        return hmacSHA256(key: accessKeySecret, message: challenge)
    }

    private func hmacSHA256(key: String, message: String) -> String {
        guard let keyData = key.data(using: .utf8) else {
            fatalError("Failed to convert key to UTF-8 data")
        }
        guard let msgData = message.data(using: .utf8) else {
            fatalError("Failed to convert message to UTF-8 data")
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        keyData.withUnsafeBytes { keyBytes in
            msgData.withUnsafeBytes { msgBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
                       keyBytes.baseAddress!,
                       keyBytes.count,
                       msgBytes.baseAddress!,
                       msgBytes.count,
                       &digest)
            }
        }

        return Data(digest).base64EncodedString()
    }
}
