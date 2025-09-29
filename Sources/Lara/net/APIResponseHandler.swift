import Foundation

public class APIResponseHandler {

    /// Handles API responses
    /// - Parameter result: The client response containing JSON data to decode
    /// - Returns: Decoded response content
    public static func handleAPIResponse<T>(_ result: ClientResponse) throws -> T where T: Codable {
        let apiResponse = try APIJSONDecoder.decode(ApiResponse<T>.self, from: result.data)
        return apiResponse.content
    }
}
