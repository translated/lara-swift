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

    public func getShares(id: String) async throws -> GlossaryShares {
        let result = try await client.get(path: "/v2/glossaries/\(id)/shares")
        return try result.decoded(as: GlossaryShares.self)
    }

    public func addAccountShare(id: String, name: String? = nil) async throws -> Glossary {
        let result = try await client.post(path: "/v2/glossaries/\(id)/shares", params: ShareParameters.make(name: name))
        return try result.decoded(as: Glossary.self)
    }

    public func renameAccountShare(id: String, name: String) async throws -> Glossary {
        let result = try await client.put(path: "/v2/glossaries/\(id)/shares", params: ShareParameters.make(name: name))
        return try result.decoded(as: Glossary.self)
    }

    public func revokeAccountShare(id: String) async throws -> Glossary {
        let result = try await client.delete(path: "/v2/glossaries/\(id)/shares")
        return try result.decoded(as: Glossary.self)
    }

    public func addGroupShare(id: String, groupId: String, name: String? = nil) async throws -> Glossary {
        let result = try await client.post(path: "/v2/glossaries/\(id)/shares/groups/\(groupId)", params: ShareParameters.make(name: name))
        return try result.decoded(as: Glossary.self)
    }

    public func renameGroupShare(id: String, groupId: String, name: String) async throws -> Glossary {
        let result = try await client.put(path: "/v2/glossaries/\(id)/shares/groups/\(groupId)", params: ShareParameters.make(name: name))
        return try result.decoded(as: Glossary.self)
    }

    public func revokeGroupShare(id: String, groupId: String) async throws -> Glossary {
        let result = try await client.delete(path: "/v2/glossaries/\(id)/shares/groups/\(groupId)")
        return try result.decoded(as: Glossary.self)
    }

    /// Imports a glossary with independent named options. gzip marks already compressed data.
    public func importFile(id: String, file: Data, contentType: GlossaryFileFormat = .csvTableUni, gzip: Bool = false, callbackUrl: String? = nil) async throws -> GlossaryImport {
        var params: [String: Any] = ["content_type": contentType.rawValue]
        if gzip {
            params["compression"] = "gzip"
        }
        if let callbackUrl {
            params["callback_url"] = callbackUrl
        }

        let files = ["csv": file]
        let filenames = ["csv": contentType == .tbx ? "glossary.tbx" : "glossary.csv"]

        let result = try await client.post(path: "/v2/glossaries/\(id)/import", params: params, files: files, filenames: filenames)
        return try result.decoded(as: GlossaryImport.self)
    }

    @available(*, deprecated, message: "Use importFile(id:file:contentType:gzip:callbackUrl:) instead.")
    public func importCsv(id: String, csv: Data, gzip: Bool = false, callbackUrl: String? = nil) async throws -> GlossaryImport {
        return try await importFile(id: id, file: csv, gzip: gzip, callbackUrl: callbackUrl)
    }

    @available(*, deprecated, message: "Use importFile(id:file:contentType:gzip:callbackUrl:) instead.")
    public func importCsv(id: String, csv: Data, contentType: GlossaryFileFormat, callbackUrl: String? = nil) async throws -> GlossaryImport {
        try validateCsvContentType(contentType)
        return try await importFile(id: id, file: csv, contentType: contentType, callbackUrl: callbackUrl)
    }

    @available(*, deprecated, renamed: "importFile(id:file:contentType:gzip:callbackUrl:)")
    public func importCsv(id: String, csv: Data, contentType: GlossaryFileFormat, gzip: Bool, callbackUrl: String? = nil) async throws -> GlossaryImport {
        try validateCsvContentType(contentType)
        return try await importFile(id: id, file: csv, contentType: contentType, gzip: gzip, callbackUrl: callbackUrl)
    }

    private func validateCsvContentType(_ contentType: GlossaryFileFormat) throws {
        if contentType == .tbx {
            throw LaraValidationError("importCsv only supports CSV formats; use importFile for TBX files.")
        }
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

    /// Exports a glossary in the requested format.
    /// - Parameters:
    ///   - id: The glossary ID to export
    ///   - contentType: A Lara glossary file format identifier, such as `csv/table-uni` or `tbx`
    ///   - source: Required for unidirectional CSV; omit for multidirectional CSV and TBX
    /// - Returns: Exported CSV or TBX content as UTF-8 text
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
    ///   - source: Required for unidirectional CSV; omit for multidirectional CSV and TBX
    /// - Returns: Exported CSV or TBX content as UTF-8 text
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

    public func exportAsync(id: String, callbackUrl: String, contentType: GlossaryFileFormat, source: String? = nil) async throws -> GlossaryExport {
        var params: [String: Any] = [
            "callback_url": callbackUrl,
            "content_type": contentType.rawValue
        ]
        if let source {
            params["source"] = source
        }

        let result = try await client.get(path: "/v2/glossaries/\(id)/export/async", params: params)
        return try result.decoded(as: GlossaryExport.self)
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
