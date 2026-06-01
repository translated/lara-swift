import Foundation

public class Styleguides {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    public func list() async throws -> [Styleguide] {
        let result = try await client.get(path: "/v2/styleguides")
        return try result.decoded(as: [Styleguide].self)
    }

    public func get(id: String) async throws -> Styleguide? {
        do {
            let result = try await client.get(path: "/v2/styleguides/\(id)")
            return try result.decoded(as: Styleguide.self)
        } catch let error as LaraApiError where error.statusCode == 404 {
            return nil
        }
    }

    public func create(name: String, content: String) async throws -> Styleguide {
        let params: [String: Any] = [
            "name": name,
            "content": content
        ]
        let result = try await client.post(path: "/v2/styleguides", params: params)
        return try result.decoded(as: Styleguide.self)
    }

    public func update(id: String, name: String? = nil, content: String? = nil) async throws -> Styleguide {
        var params: [String: Any] = [:]
        if let name { params["name"] = name }
        if let content { params["content"] = content }
        let result = try await client.put(path: "/v2/styleguides/\(id)", params: params)
        return try result.decoded(as: Styleguide.self)
    }

    public func delete(id: String) async throws -> Styleguide {
        let result = try await client.delete(path: "/v2/styleguides/\(id)")
        return try result.decoded(as: Styleguide.self)
    }
}
