import Foundation

public class Memories {
    private let client: Client
    private let pollingInterval: TimeInterval
    
    init(client: Client, pollingInterval: TimeInterval = 2.0) {
        self.client = client
        self.pollingInterval = pollingInterval
    }

    
    public func list() async throws -> [Memory] {
        let result = try await client.get(path: "/v2/memories")
        return try result.decoded(as: [Memory].self)
    }

    public func get(id: String) async throws -> Memory {
        let result = try await client.get(path: "/v2/memories/\(id)")
        return try result.decoded(as: Memory.self)
    }

    public func create(name: String, externalId: String?) async throws -> Memory {
        var params: [String: Any] = [
            "name": name
        ]

        if let externalId = externalId {
            params["external_id"] = externalId
        }

        let result = try await client.post(path: "/v2/memories", params: params)
        return try result.decoded(as: Memory.self)
    }

    public func update(id: String, name: String) async throws -> Memory {
        let params: [String: Any] = [
            "name": name
        ]

        let result = try await client.put(path: "/v2/memories/\(id)", params: params)
        return try result.decoded(as: Memory.self)
    }

    public func connect(id: String) async throws -> Memory {
        let params: [String: Any] = [
            "ids": [id]
        ]

        let response = try await client.post(path: "/v2/memories/connect", params: params)
        let memories = try response.decoded(as: [Memory].self)
        guard let memory = memories.first else {
            throw LaraApiError(statusCode: 404, type: "NotFound", message: "No memory found")
        }
        return memory
    }

    public func connect(ids: [String]) async throws -> [Memory] {
        let params: [String: Any] = [
            "ids": ids
        ]

        let response = try await client.post(path: "/v2/memories/connect", params: params)
        return try response.decoded(as: [Memory].self)
    }

    // MARK: - Translation Management

    public func addTranslation(
        id: String,
        source: String,
        target: String,
        sentence: String,
        translation: String,
        tuid: String? = nil,
        sentenceBefore: String? = nil,
        sentenceAfter: String? = nil,
        headers: [String: String]? = nil
    ) async throws -> MemoryImport {
        var params: [String: Any] = [
            "source": source,
            "target": target,
            "sentence": sentence,
            "translation": translation
        ]

        if let tuid = tuid {
            params["tuid"] = tuid
        }
        if let sentenceBefore = sentenceBefore {
            params["sentence_before"] = sentenceBefore
        }
        if let sentenceAfter = sentenceAfter {
            params["sentence_after"] = sentenceAfter
        }

        let result = try await client.put(path: "/v2/memories/\(id)/content", params: params, headers: headers)
        return try result.decoded(as: MemoryImport.self)
    }

    public func addTranslation(
        ids: [String],
        source: String,
        target: String,
        sentence: String,
        translation: String,
        tuid: String? = nil,
        sentenceBefore: String? = nil,
        sentenceAfter: String? = nil,
        headers: [String: String]? = nil
    ) async throws -> MemoryImport {
        var params: [String: Any] = [
            "ids": ids,
            "source": source,
            "target": target,
            "sentence": sentence,
            "translation": translation
        ]

        if let tuid = tuid {
            params["tuid"] = tuid
        }
        if let sentenceBefore = sentenceBefore {
            params["sentence_before"] = sentenceBefore
        }
        if let sentenceAfter = sentenceAfter {
            params["sentence_after"] = sentenceAfter
        }

        let result = try await client.put(path: "/v2/memories/content", params: params, headers: headers)
        return try result.decoded(as: MemoryImport.self)
    }

    public func deleteTranslation(
        id: String,
        source: String,
        target: String,
        sentence: String,
        translation: String,
        tuid: String? = nil,
        sentenceBefore: String? = nil,
        sentenceAfter: String? = nil
    ) async throws -> MemoryImport {
        var params: [String: Any] = [
            "source": source,
            "target": target,
            "sentence": sentence,
            "translation": translation
        ]

        if let tuid = tuid {
            params["tuid"] = tuid
        }
        if let sentenceBefore = sentenceBefore {
            params["sentence_before"] = sentenceBefore
        }
        if let sentenceAfter = sentenceAfter {
            params["sentence_after"] = sentenceAfter
        }

        let result = try await client.delete(path: "/v2/memories/\(id)/content", params: params)
        return try result.decoded(as: MemoryImport.self)
    }

    public func deleteTranslation(
        ids: [String],
        source: String,
        target: String,
        sentence: String,
        translation: String,
        tuid: String? = nil,
        sentenceBefore: String? = nil,
        sentenceAfter: String? = nil
    ) async throws -> MemoryImport {
        var params: [String: Any] = [
            "ids": ids,
            "source": source,
            "target": target,
            "sentence": sentence,
            "translation": translation
        ]

        if let tuid = tuid {
            params["tuid"] = tuid
        }
        if let sentenceBefore = sentenceBefore {
            params["sentence_before"] = sentenceBefore
        }
        if let sentenceAfter = sentenceAfter {
            params["sentence_after"] = sentenceAfter
        }

        let result = try await client.delete(path: "/v2/memories/content", params: params)
        return try result.decoded(as: MemoryImport.self)
    }

    public func importTmx(id: String, tmx: Data, gzip: Bool = false) async throws -> MemoryImport {
        var params: [String: Any] = [:]
        if gzip {
            params["compression"] = "gzip"
        }

        let files = ["tmx": tmx]

        let result = try await client.post(path: "/v2/memories/\(id)/import", params: params, files: files)
        return try result.decoded(as: MemoryImport.self)
    }

    public func getImportStatus(id: String) async throws -> MemoryImport {
        let result = try await client.get(path: "/v2/memories/imports/\(id)")
        return try result.decoded(as: MemoryImport.self)
    }

    public func delete(id: String) async throws -> Memory {
        let result = try await client.delete(path: "/v2/memories/\(id)")
        return try result.decoded(as: Memory.self)
    }

    // MARK: - Import Management

    /// Waits for a memory import to complete by polling the import status.
    /// - Parameters:
    ///   - memoryImport: The memory import to wait for
    ///   - updateCallback: Optional callback called with progress updates
    ///   - maxWaitTime: Maximum time to wait in seconds (defaults to 5 minutes)
    /// - Returns: final MemoryImport
    public func waitForImport(
        _ memoryImport: MemoryImport,
        updateCallback: ((MemoryImport) -> Void)? = nil,
        maxWaitTime: TimeInterval = 300
    ) async throws -> MemoryImport {
        return try await Poller.poll(
            initial: memoryImport,
            interval: pollingInterval,
            maxTime: maxWaitTime,
            next: { [weak self] currentImport in
                guard let self = self else {
                    throw LaraApiConnectionError("Memories client deallocated during polling")
                }
                return try await self.getImportStatus(id: currentImport.id)
            },
            isFinished: { $0.progress >= 1.0 },
            progress: updateCallback
        )
    }
}
