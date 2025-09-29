import Foundation

public struct ClientResponse {
    public let data: Data
    public let httpResponse: HTTPURLResponse
    public let decoder: JSONDecoder
}



