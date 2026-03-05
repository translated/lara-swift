import Foundation

@available(*, deprecated, message: "Use AccessKey(id:secret:) instead")
public class Credentials: AccessKey {
    public init(accessKeyId: String, accessKeySecret: String) {
        super.init(id: accessKeyId, secret: accessKeySecret)
    }

    public var accessKeyId: String { return id }
    public var accessKeySecret: String { return secret }
}
