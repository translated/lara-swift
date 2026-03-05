import Foundation

public class AuthToken {
    public let token: String
    public let refreshToken: String

    public init(token: String, refreshToken: String) {
        self.token = token
        self.refreshToken = refreshToken
    }
}
