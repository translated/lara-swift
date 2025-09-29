import Foundation

/// Utility class for API JSON decoding with standard date formatting
public class APIJSONDecoder {
    private static let sharedDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return try sharedDecoder.decode(type, from: data)
    }

    public static func decoder() -> JSONDecoder {
        return sharedDecoder
    }
}
