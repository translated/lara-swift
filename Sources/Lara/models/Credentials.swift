import Foundation

public class Credentials {
    public let accessKeyId: String
    public let accessKeySecret: String
    
    public init(accessKeyId: String, accessKeySecret: String) {
        self.accessKeyId = accessKeyId
        self.accessKeySecret = accessKeySecret
    }
}
