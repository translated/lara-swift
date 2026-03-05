import Foundation

public struct ClientResponse {
    public let data: Data
    public let httpResponse: HTTPURLResponse
    public let decoder: JSONDecoder
}

// MARK: - Generic Decoding Extensions
extension ClientResponse {

    internal func decoded<T: Codable>(as type: T.Type) throws -> T {
        return try APIJSONDecoder.decode(T.self, from: data)
    }

    internal func decodedArray<T: Codable>(as type: T.Type) throws -> [T] {
        return try APIJSONDecoder.decode([T].self, from: data)
    }
}



