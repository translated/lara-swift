import Foundation

public class Styleguides {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    @available(*, deprecated, message: "Use listPaginated(options:) instead.")
    public func list() async throws -> [Styleguide] {
        let result = try await client.get(path: "/v2/styleguides")
        return try result.decoded(as: [Styleguide].self)
    }

    /// Lists resources with optional name filtering and pagination.
    /// Without options, returns the complete list without pagination.
    /// Providing search, page, or size enables pagination, defaulting to page 1 and size 20.
    public func listPaginated(options: ResourceQueryOptions? = nil) async throws -> CollectionResult<Styleguide> {
        return try await client.getCollection(path: "/v2/styleguides", options: options)
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

    public func getShares(id: String) async throws -> StyleguideShares {
        let result = try await client.get(path: "/v2/styleguides/\(id)/shares")
        return try result.decoded(as: StyleguideShares.self)
    }

    public func addAccountShare(id: String, name: String? = nil) async throws -> Styleguide {
        let result = try await client.post(path: "/v2/styleguides/\(id)/shares", params: ShareParameters.make(name: name))
        return try result.decoded(as: Styleguide.self)
    }

    public func renameAccountShare(id: String, name: String) async throws -> Styleguide {
        let result = try await client.put(path: "/v2/styleguides/\(id)/shares", params: ShareParameters.make(name: name))
        return try result.decoded(as: Styleguide.self)
    }

    public func revokeAccountShare(id: String) async throws -> Styleguide {
        let result = try await client.delete(path: "/v2/styleguides/\(id)/shares")
        return try result.decoded(as: Styleguide.self)
    }

    public func addGroupShare(id: String, groupId: String, name: String? = nil) async throws -> Styleguide {
        let result = try await client.post(path: "/v2/styleguides/\(id)/shares/groups/\(groupId)", params: ShareParameters.make(name: name))
        return try result.decoded(as: Styleguide.self)
    }

    public func renameGroupShare(id: String, groupId: String, name: String) async throws -> Styleguide {
        let result = try await client.put(path: "/v2/styleguides/\(id)/shares/groups/\(groupId)", params: ShareParameters.make(name: name))
        return try result.decoded(as: Styleguide.self)
    }

    public func revokeGroupShare(id: String, groupId: String) async throws -> Styleguide {
        let result = try await client.delete(path: "/v2/styleguides/\(id)/shares/groups/\(groupId)")
        return try result.decoded(as: Styleguide.self)
    }
}
