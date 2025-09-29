import Foundation


public class Glossaries {
    private let client: Client
    private let pollingInterval: TimeInterval

    init(client: Client, pollingInterval: TimeInterval = 2.0) {
        self.client = client
        self.pollingInterval = pollingInterval
    }


    public func list() async throws -> [Glossary] {
        let result = try await client.get(path: "/glossaries")
        return try APIResponseHandler.handleAPIResponse(result)
    }

    public func get(id: String) async throws -> Glossary {
        let result = try await client.get(path: "/glossaries/\(id)")
        return try APIResponseHandler.handleAPIResponse(result)
    }

    public func create(name: String) async throws -> Glossary {
        let params: [String: Any] = [
            "name": name
        ]

        let result = try await client.post(path: "/glossaries", params: params)
        return try APIResponseHandler.handleAPIResponse(result)
    }

    public func update(id: String, name: String) async throws -> Glossary {
        let params: [String: Any] = [
            "name": name
        ]

        let result = try await client.put(path: "/glossaries/\(id)", params: params)
        return try APIResponseHandler.handleAPIResponse(result)
    }

    public func delete(id: String) async throws -> Glossary {
        let result = try await client.delete(path: "/glossaries/\(id)")
        return try APIResponseHandler.handleAPIResponse(result)
    }

    public func importCsv(id: String, csv: Data, gzip: Bool = false) async throws -> GlossaryImport {
        var params: [String: Any] = [:]
        if gzip {
            params["compression"] = "gzip"
        }

        let files = ["csv": csv]

        let result = try await client.post(path: "/glossaries/\(id)/import", params: params, files: files)
        return try APIResponseHandler.handleAPIResponse(result)
    }

    public func getImportStatus(id: String) async throws -> GlossaryImport {
        let result = try await client.get(path: "/glossaries/imports/\(id)")
        return try APIResponseHandler.handleAPIResponse(result)
    }

    public func counts(id: String) async throws -> GlossaryCounts {
        let result = try await client.get(path: "/glossaries/\(id)/counts")
        return try APIResponseHandler.handleAPIResponse(result)
    }

    // MARK: - Import Management

    /// Waits for a glossary import to complete by polling the import status.
    /// - Parameters:
    ///   - glossaryImport: The glossary import to wait for
    ///   - updateCallback: Optional callback called with progress updates
    ///   - maxWaitTime: Maximum time to wait in seconds (defaults to 5 minutes)
    /// - Returns: final GlossaryImport
    public func waitForImport(
        _ glossaryImport: GlossaryImport,
        updateCallback: ((GlossaryImport) -> Void)? = nil,
        maxWaitTime: TimeInterval = 300
    ) async throws -> GlossaryImport {
        return try await Poller.poll(
            initial: glossaryImport,
            interval: pollingInterval,
            maxTime: maxWaitTime,
            next: { [weak self] currentImport in
                guard let self = self else {
                    throw LaraApiConnectionError("Glossary client deallocated during polling")
                }
                return try await self.getImportStatus(id: currentImport.id)
            },
            isFinished: { $0.progress >= 1.0 },
            progress: updateCallback
        )
    }

    /// Exports a glossary in CSV format.
    /// - Parameters:
    ///   - id: The glossary ID to export
    ///   - contentType: csv/table-uni
    ///   - source: Optional source language filter
    /// - Returns: exported CSV data
    public func export(id: String, contentType: String = "csv/table-uni", source: String? = nil) async throws -> String {
        var params: [String: Any] = ["content_type": contentType]
        if let source = source {
            params["source"] = source
        }

        let response = try await client.get(path: "/glossaries/\(id)/export", params: params)
        guard let csvString = String(data: response.data, encoding: .utf8) else {
            throw LaraApiConnectionError("Failed to decode export data")
        }
        return csvString
    }
}