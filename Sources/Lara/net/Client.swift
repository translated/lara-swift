import Foundation
import CommonCrypto
import CryptoKit

public class Client {

    private let baseUrl: URL
    private let accessKeyId: String?
    private let accessKeySecret: String?

    private var token: String?
    private var refreshToken: String?
    private var tokenExpiresAtMs: Int64 = 0

    public let connectionTimeout: TimeInterval
    public let readTimeout: TimeInterval
    internal var extraHeaders: [String: String] = [:]

    private let jsonDecoder: JSONDecoder = APIJSONDecoder.decoder()

    // MARK: - Init
    public init(accessKey: AccessKey, options: ClientOptions = ClientOptions()) {
        self.accessKeyId = accessKey.id
        self.accessKeySecret = accessKey.secret
        self.baseUrl = options.serverUrl
        self.connectionTimeout = options.connectionTimeout
        self.readTimeout = options.readTimeout
    }

    public init(authToken: AuthToken, options: ClientOptions = ClientOptions()) {
        self.accessKeyId = nil
        self.accessKeySecret = nil
        self.baseUrl = options.serverUrl
        self.connectionTimeout = options.connectionTimeout
        self.readTimeout = options.readTimeout
        self.token = authToken.token
        self.refreshToken = authToken.refreshToken
        self.tokenExpiresAtMs = Client.parseJwtExpiresAtMs(authToken.token)
    }

    @available(*, deprecated, message: "Use init(accessKey:) with AccessKey instead")
    public convenience init(credentials: Credentials, options: ClientOptions = ClientOptions()) {
        self.init(accessKey: credentials, options: options)
    }

    // MARK: - Extra headers
    public func setExtraHeader(name: String, value: String) {
        extraHeaders[name] = value
    }

    // MARK: - HTTP Methods
    public func get(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        return try await request(method: "GET", path: path, params: params, files: nil, headers: headers)
    }

    public func post(path: String, params: [String: Any]? = nil, files: [String: Data]? = nil, filenames: [String: String]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        let multipartFiles: [String: MultipartFile]?

        if let files = files {
            multipartFiles = Dictionary(uniqueKeysWithValues: files.map { key, data in
                let filename = filenames?[key] ?? UUID().uuidString
                return (key, MultipartFile(filename: filename, data: data))
            })
        } else {
            multipartFiles = nil
        }

        return try await request(method: "POST", path: path, params: params, files: multipartFiles, headers: headers)
    }

    public func put(path: String, params: [String: Any]? = nil, files: [String: Data]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        let multipartFiles = files?.mapValues { data in MultipartFile(filename: UUID().uuidString, data: data) }
        return try await request(method: "PUT", path: path, params: params, files: multipartFiles, headers: headers)
    }

    public func delete(path: String, params: [String: Any]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        try await request(method: "DELETE", path: path, params: params, files: nil, headers: headers)
    }

    public func postStream(path: String, params: [String: Any]? = nil, files: [String: Data]? = nil, headers: [String: String]? = nil, callback: ((Any) -> Void)? = nil) async throws -> ClientResponse {
        let multipartFiles = files?.mapValues { data in MultipartFile(filename: UUID().uuidString, data: data) }
        return try await streamRequest(path: path, params: params, files: multipartFiles, headers: headers, callback: callback, isRetry: false)
    }

    // MARK: - Core request
    private func request(method: String, path: String, params: [String: Any]?, files: [String: MultipartFile]?, headers: [String: String]?, isRetry: Bool = false) async throws -> ClientResponse {
        let token = try await ensureValidToken()

        let prunedParams = prune(params)

        let normalizedPath = path.hasPrefix("/") ? path : "/" + path
        let finalUrl = baseUrl.appendingPathComponent(normalizedPath)

        var requestUrl = finalUrl
        let requestBody: RequestBody?

        if method == "GET" {
            if !prunedParams.isEmpty {
                var components = URLComponents(url: finalUrl, resolvingAgainstBaseURL: false)!
                var queryItems = components.queryItems ?? []
                for (key, value) in prunedParams {
                    queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
                }
                components.queryItems = queryItems
                requestUrl = components.url!
                requestBody = nil
            } else {
                requestBody = nil
            }
        } else {
            if let files = files, !files.isEmpty {
                requestBody = MultipartRequestBody(params: prunedParams, files: files)
            } else if !prunedParams.isEmpty {
                requestBody = try JsonRequestBody(params: prunedParams)
            } else {
                requestBody = try JsonRequestBody(params: [:])
            }
        }

        var urlRequest = URLRequest(url: requestUrl, timeoutInterval: connectionTimeout)
        urlRequest.httpMethod = method
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData

        let dateString = httpDate()
        urlRequest.setValue(dateString, forHTTPHeaderField: "Date")
        urlRequest.setValue("lara-swift", forHTTPHeaderField: "X-Lara-SDK-Name")

        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        extraHeaders.forEach { key, value in urlRequest.setValue(value, forHTTPHeaderField: key) }
        headers?.forEach { key, value in urlRequest.setValue(value, forHTTPHeaderField: key) }

        if let body = requestBody {
            urlRequest.setValue(body.contentType(), forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(body.contentLength())", forHTTPHeaderField: "Content-Length")

            let bodyData = try createBodyData(from: body)
            urlRequest.httpBody = bodyData
        }

        let response = try await executeRequest(urlRequest)

        if response.httpResponse.statusCode == 401 && !isRetry {
            try await refreshOrReauthenticate()
            return try await request(method: method, path: path, params: params, files: files, headers: headers, isRetry: true)
        }

        if !(200..<300).contains(response.httpResponse.statusCode) {
            let error: [String: Any] = (try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any])?["error"] as? [String: Any] ?? [:]
            throw LaraApiError(
                statusCode: response.httpResponse.statusCode,
                type: error["type"] as? String ?? "UnknownError",
                message: error["message"] as? String ?? "An unknown error occurred"
            )
        }

        return response
    }

    private func streamRequest(path: String, params: [String: Any]?, files: [String: MultipartFile]?, headers: [String: String]?, callback: ((Any) -> Void)?, isRetry: Bool = false) async throws -> ClientResponse {
        let token = try await ensureValidToken()

        let prunedParams = prune(params)

        let normalizedPath = path.hasPrefix("/") ? path : "/" + path
        let finalUrl = baseUrl.appendingPathComponent(normalizedPath)

        let requestUrl = finalUrl
        let requestBody: RequestBody?

        if let files = files, !files.isEmpty {
            requestBody = MultipartRequestBody(params: prunedParams, files: files)
        } else if !prunedParams.isEmpty {
            requestBody = try JsonRequestBody(params: prunedParams)
        } else {
            requestBody = try JsonRequestBody(params: [:])
        }

        var urlRequest = URLRequest(url: requestUrl, timeoutInterval: connectionTimeout)
        urlRequest.httpMethod = "POST"
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData

        let dateString = httpDate()
        urlRequest.setValue(dateString, forHTTPHeaderField: "Date")
        urlRequest.setValue("lara-swift", forHTTPHeaderField: "X-Lara-SDK-Name")

        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        extraHeaders.forEach { key, value in urlRequest.setValue(value, forHTTPHeaderField: key) }
        headers?.forEach { key, value in urlRequest.setValue(value, forHTTPHeaderField: key) }

        if let body = requestBody {
            urlRequest.setValue(body.contentType(), forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(body.contentLength())", forHTTPHeaderField: "Content-Length")

            let bodyData = try createBodyData(from: body)
            urlRequest.httpBody = bodyData
        }

        let (response, shouldRetryAuth) = try await executeStreamRequest(urlRequest, callback: callback)

        if shouldRetryAuth && !isRetry {
            try await refreshOrReauthenticate()
            return try await streamRequest(path: path, params: params, files: files, headers: headers, callback: callback, isRetry: true)
        }

        return response
    }

    private func ensureValidToken() async throws -> String {
        if let existingToken = token, !existingToken.isEmpty, !isTokenExpired() {
            return existingToken
        }

        try await refreshOrReauthenticate()

        guard let validToken = token, !validToken.isEmpty else {
            throw LaraApiError(statusCode: 401, type: "AuthenticationError", message: "No valid access token available")
        }

        return validToken
    }

    private func refreshOrReauthenticate() async throws {
        if let rt = refreshToken, !rt.isEmpty {
            do {
                try await refresh()
                return
            } catch {
                if accessKeyId == nil || accessKeySecret == nil { throw error }
            }
        }

        if accessKeyId != nil && accessKeySecret != nil {
            try await authenticate()
            return
        }

        throw LaraApiConnectionError("No authentication method available for token renewal")
    }

    private func isTokenExpired() -> Bool {
        return tokenExpiresAtMs <= Int64(Date().timeIntervalSince1970 * 1000) + 5000
    }

    private static func parseJwtExpiresAtMs(_ token: String) -> Int64 {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return 0 }

        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? Double else {
            return 0
        }

        return Int64(exp * 1000)
    }

    private func authenticate() async throws {
        guard let accessKeyId = accessKeyId, let accessKeySecret = accessKeySecret else {
            throw LaraApiError(statusCode: 401, type: "AuthenticationError", message: "No authentication credentials available")
        }

        let authParams = ["id": accessKeyId]
        let bodyData = try JSONSerialization.data(withJSONObject: authParams)

        let dateString = httpDate()
        let path = "/v2/auth"

        var headers: [String: String] = [
            "Date": dateString,
            "X-Lara-SDK-Name": "lara-swift",
            "Content-MD5": md5(data: bodyData),
            "Content-Type": "application/json"
        ]

        if let version = Version.get() {
            headers["X-Lara-SDK-Version"] = version
        }

        let signature = generateSignature(
            method: "POST",
            path: path,
            body: bodyData,
            date: dateString,
            secret: accessKeySecret,
            contentType: "application/json"
        )

        headers["Authorization"] = "Lara:\(signature)"

        let response: ClientResponse = try await makeAuthRequest(
            method: "POST",
            path: path,
            params: authParams,
            headers: headers
        )

        let authData = try response.decoder.decode([String: String].self, from: response.data)

        guard let authToken = authData["token"], !authToken.isEmpty else {
            throw LaraApiError(statusCode: response.httpResponse.statusCode, type: "AuthenticationError", message: "Failed to obtain access token. Response: \(authData)")
        }

        self.token = authToken
        self.refreshToken = response.httpResponse.value(forHTTPHeaderField: "X-Lara-Refresh-Token")
        self.tokenExpiresAtMs = Client.parseJwtExpiresAtMs(authToken)
    }

    private func refresh() async throws {
        guard let refreshToken = refreshToken else {
            throw LaraApiError(statusCode: 401, type: "AuthenticationError", message: "No refresh token available")
        }

        let response: ClientResponse = try await makeAuthRequest(
            method: "POST",
            path: "/v2/auth/refresh",
            headers: ["Authorization": "Bearer \(refreshToken)"]
        )

        let refreshData = try response.decoder.decode([String: String].self, from: response.data)

        guard let refreshAuthToken = refreshData["token"], !refreshAuthToken.isEmpty else {
            self.token = nil
            self.refreshToken = nil
            throw LaraApiError(statusCode: response.httpResponse.statusCode, type: "AuthenticationError", message: "Failed to refresh access token")
        }

        self.token = refreshAuthToken
        self.refreshToken = response.httpResponse.value(forHTTPHeaderField: "X-Lara-Refresh-Token")
        self.tokenExpiresAtMs = Client.parseJwtExpiresAtMs(refreshAuthToken)
    }

    private func makeAuthRequest(method: String, path: String, params: [String: Any]? = nil, headers: [String: String]? = nil) async throws -> ClientResponse {
        let fullUrl = baseUrl.appendingPathComponent(path.hasPrefix("/") ? path : "/" + path)

        var request = URLRequest(url: fullUrl)
        request.httpMethod = method
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let dateString = httpDate()
        request.setValue(dateString, forHTTPHeaderField: "Date")
        request.setValue("lara-swift", forHTTPHeaderField: "X-Lara-SDK-Name")
        if let version = Version.get() {
            request.setValue(version, forHTTPHeaderField: "X-Lara-SDK-Version")
        }

        headers?.forEach { key, value in request.setValue(value, forHTTPHeaderField: key) }

        if let params = params, !params.isEmpty {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
        }

        return try await executeRequest(request)
    }

    private func prune(_ params: [String: Any]?) -> [String: Any] {
        guard let params = params else { return [:] }
        return params.compactMapValues { value in
            switch value {
            case is NSNull, Optional<Any>.none:
                return nil
            default:
                return value
            }
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

    private func executeStreamRequest(_ request: URLRequest, callback: ((Any) -> Void)?) async throws -> (ClientResponse, shouldRetryAuth: Bool) {
        let (bytes, urlResponse) = try await URLSession.shared.bytes(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw LaraApiConnectionError("Failed to get response")
        }

        if !(200..<300).contains(httpResponse.statusCode) && httpResponse.statusCode != 401 {
            var errorData = Data()
            for try await byte in bytes {
                errorData.append(byte)
            }
            let error: [String: Any] = (try? JSONSerialization.jsonObject(with: errorData, options: []) as? [String: Any])?["error"] as? [String: Any] ?? [:]
            throw LaraApiError(
                statusCode: httpResponse.statusCode,
                type: error["type"] as? String ?? "UnknownError",
                message: error["message"] as? String ?? "An unknown error occurred"
            )
        }

        var lastData: Data?
        var lastResult: [String: Any]?

        for try await line in bytes.lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty { continue }

            if let data = trimmedLine.data(using: .utf8),
               let parsed = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                lastResult = parsed
                let result = parsed["content"] ?? parsed
                if let content = parsed["content"] {
                    lastData = try? JSONSerialization.data(withJSONObject: content, options: [])
                } else {
                    lastData = data
                }
                callback?(result)
            }
        }

        let shouldRetryAuth = httpResponse.statusCode == 401

        guard let finalData = lastData else {
            throw LaraApiError(statusCode: 500, type: "StreamingError", message: "No data received from stream")
        }

        let response = ClientResponse(data: finalData, httpResponse: httpResponse, decoder: self.jsonDecoder)
        return (response, shouldRetryAuth: shouldRetryAuth)
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

    // MARK: - Cryptographic Functions

    private func md5(data: Data) -> String {
        let digest = Insecure.MD5.hash(data: data)
        return Data(digest).base64EncodedString()
    }

    private func hmacSHA256(key: String, data: String) -> String {
        let keyData = key.data(using: .utf8)!
        let dataData = data.data(using: .utf8)!
        let symmetricKey = SymmetricKey(data: keyData)
        let signature = HMAC<SHA256>.authenticationCode(for: dataData, using: symmetricKey)
        return Data(signature).base64EncodedString()
    }

    private func generateSignature(method: String, path: String, body: Data, date: String, secret: String, contentType: String = "application/json") -> String {
        let contentMD5 = md5(data: body)
        let challenge = "\(method)\n\(path)\n\(contentMD5)\n\(contentType)\n\(date)"
        return hmacSHA256(key: secret, data: challenge)
    }
}
