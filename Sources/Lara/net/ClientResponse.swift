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

    internal func decodedCollection<T: Codable>(as type: T.Type) throws -> CollectionResult<T> {
        func readIntegerHeader(_ name: String, minimum: Int) -> Int? {
            let fields = httpResponse.allHeaderFields.filter {
                ($0.key as? String)?.caseInsensitiveCompare(name) == .orderedSame
            }
            guard fields.count == 1,
                  let rawValue = fields.first?.value as? String else {
                return nil
            }
            let value = rawValue.trimmingCharacters(in: CharacterSet(charactersIn: " \t"))
            guard !value.isEmpty,
                  value.allSatisfy({ ("0"..."9").contains($0) }),
                  let number = Int(value), number >= minimum else {
                return nil
            }
            return number
        }

        guard let total = readIntegerHeader("X-Total-Count", minimum: 0) else {
            throw LaraApiConnectionError("Missing or invalid X-Total-Count response header")
        }

        return CollectionResult(
            items: try decodedArray(as: type),
            total: total,
            page: readIntegerHeader("X-Page", minimum: 1),
            size: readIntegerHeader("X-Page-Size", minimum: 1)
        )
    }
}



