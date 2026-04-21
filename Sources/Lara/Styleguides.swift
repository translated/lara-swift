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
}
