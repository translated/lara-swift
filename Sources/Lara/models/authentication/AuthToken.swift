import Foundation

public class AuthToken {
    public let token: String
    public let refreshToken: String
    private let expiresAtMs: Int64

    public init(token: String, refreshToken: String) {
        self.token = token
        self.refreshToken = refreshToken
        self.expiresAtMs = AuthToken.parseExpiresAtMs(token)
    }

    public func isTokenExpired() -> Bool {
        return expiresAtMs <= Int64(Date().timeIntervalSince1970 * 1000) + 5000
    }

    private static func parseExpiresAtMs(_ token: String) -> Int64 {
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
}
