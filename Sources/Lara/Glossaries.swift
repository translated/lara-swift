import Foundation


public class Glossaries {
    private let client: Client
    private let pollingInterval: TimeInterval

    init(client: Client, pollingInterval: TimeInterval = 2.0) {
        self.client = client
        self.pollingInterval = pollingInterval
    }


    public func list() async throws -> [Glossary] {
        let result = try await client.get(path: "/v2/glossaries")
        return try result.decoded(as: [Glossary].self)
    }

    public func get(id: String) async throws -> Glossary {
        let result = try await client.get(path: "/v2/glossaries/\(id)")
        return try result.decoded(as: Glossary.self)
    }

    public func create(name: String) async throws -> Glossary {
        let params: [String: Any] = [
            "name": name
        ]

        let result = try await client.post(path: "/v2/glossaries", params: params)
        return try result.decoded(as: Glossary.self)
    }

    public func update(id: String, name: String) async throws -> Glossary {
        let params: [String: Any] = [
            "name": name
        ]

        let result = try await client.put(path: "/v2/glossaries/\(id)", params: params)
        return try result.decoded(as: Glossary.self)
    }

    public func delete(id: String) async throws -> Glossary {
        let result = try await client.delete(path: "/v2/glossaries/\(id)")
        return try result.decoded(as: Glossary.self)
    }

    public func importCsv(id: String, csv: Data, gzip: Bool = false) async throws -> GlossaryImport {
        return try await importCsv(id: id, csv: csv, contentType: .csvTableUni, gzip: gzip)
    }

    public func importCsv(id: String, csv: Data, contentType: GlossaryFileFormat) async throws -> GlossaryImport {
        return try await importCsv(id: id, csv: csv, contentType: contentType, gzip: false)
    }

    public func importCsv(id: String, csv: Data, contentType: GlossaryFileFormat, gzip: Bool) async throws -> GlossaryImport {
        var params: [String: Any] = ["content_type": contentType.rawValue]
        if gzip {
            params["compression"] = "gzip"
        }

        let files = ["csv": csv]

        let result = try await client.post(path: "/v2/glossaries/\(id)/import", params: params, files: files)
        return try result.decoded(as: GlossaryImport.self)
    }

    public func getImportStatus(id: String) async throws -> GlossaryImport {
        let result = try await client.get(path: "/v2/glossaries/imports/\(id)")
        return try result.decoded(as: GlossaryImport.self)
    }

    public func counts(id: String) async throws -> GlossaryCounts {
        let result = try await client.get(path: "/v2/glossaries/\(id)/counts")
        return try result.decoded(as: GlossaryCounts.self)
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

    /// Exports a glossary in unidirectional format.
    /// - Parameters:
    ///   - id: The glossary ID to export
    ///   - contentType: csv/table-uni
    ///   - source: Optional source language filter
    /// - Returns: exported CSV data
    public func export(id: String, contentType: String = "csv/table-uni", source: String? = nil) async throws -> String {
        guard let format = GlossaryFileFormat(rawValue: contentType) else {
            throw LaraValidationError("Invalid content type: \(contentType)")
        }
        return try await export(id: id, contentType: format, source: source)
    }

    /// Exports a glossary in the specified format.
    /// - Parameters:
    ///   - id: The glossary ID to export
    ///   - contentType: The file format for export
    ///   - source: Optional source language filter
    /// - Returns: exported CSV data
    public func export(id: String, contentType: GlossaryFileFormat, source: String? = nil) async throws -> String {
        var params: [String: Any] = ["content_type": contentType.rawValue]
        if let source = source {
            params["source"] = source
        }

        let response = try await client.get(path: "/v2/glossaries/\(id)/export", params: params)
        guard let csvString = String(data: response.data, encoding: .utf8) else {
            throw LaraApiConnectionError("Failed to decode export data")
        }
        return csvString
    }

    /// Adds or replaces terms in a glossary
    /// - Parameters:
    ///   - glossaryId: The glossary ID
    ///   - terms: Array of terms with language and value
    ///   - guid: Optional unique identifier for multidirectional glossary units
    /// - Returns: API response
    public func addOrReplaceEntry(glossaryId: String, terms: [[String: String]], guid: String? = nil) async throws -> ClientResponse {
        var params: [String: Any] = ["terms": terms]
        if let guid = guid {
            params["guid"] = guid
        }

        return try await client.put(path: "/v2/glossaries/\(glossaryId)/content", params: params)
    }

    /// Deletes a term from a glossary
    /// - Parameters:
    ///   - glossaryId: The glossary ID
    ///   - term: Optional term with language and value to delete
    ///   - guid: Optional unique identifier for multidirectional glossary units
    /// - Returns: API response
    public func deleteEntry(glossaryId: String, term: [String: String]? = nil, guid: String? = nil) async throws -> ClientResponse {
        var params: [String: Any] = [:]
        if let guid = guid {
            params["guid"] = guid
        }
        if let term = term {
            params["term"] = term
        }

        return try await client.delete(path: "/v2/glossaries/\(glossaryId)/content", params: params)
    }
}