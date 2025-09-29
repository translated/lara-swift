import Foundation

public struct ClientOptions {

    public static let DEFAULT_URL = "https://api.laratranslate.com"

    private let serverUrlString: String
    public let connectionTimeout: TimeInterval
    public let readTimeout: TimeInterval

    public var serverUrl: URL {
        if let url = URL(string: serverUrlString) {
            return url
        }
        guard let defaultUrl = URL(string: ClientOptions.DEFAULT_URL) else {
            fatalError("Invalid default URL: \(ClientOptions.DEFAULT_URL)")
        }
        return defaultUrl
    }

    public init(serverUrl: URL? = nil, connectionTimeout: TimeInterval = 30, readTimeout: TimeInterval = 30) {
        if let url = serverUrl {
            self.serverUrlString = url.absoluteString
        } else {
            self.serverUrlString = ClientOptions.DEFAULT_URL
        }

        self.connectionTimeout = connectionTimeout
        self.readTimeout = readTimeout
    }
}
