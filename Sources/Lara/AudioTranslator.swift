import Foundation

/// AudioTranslator class providing methods for audio translation operations
public class AudioTranslator {

    private let client: Client
    private let s3Client: S3Client
    private let pollingInterval: TimeInterval = 2.0 // seconds

    /// Initialize AudioTranslator with a client
    /// - Parameters:
    ///   - client: The Lara API client
    public init(client: Client) {
        self.client = client
        self.s3Client = S3Client()
    }


    /// Upload an audio file for translation
    /// - Parameters:
    ///   - data: The audio data to upload
    ///   - filename: Name of the audio file
    ///   - source: Source language (optional, auto-detected if nil)
    ///   - target: Target language for translation
    ///   - options: Upload options (optional)
    /// - Returns: audio information
    public func upload(
        data: Data,
        filename: String,
        source: String? = nil,
        target: String,
        options: AudioUploadOptions? = nil
    ) async throws -> Audio {
        // Step 1: Get upload URL and S3 parameters
        let uploadUrlParams: [String: Any] = ["filename": filename]

        let response = try await client.get(path: "/v2/audio/upload-url", params: uploadUrlParams)
        let uploadParams = try response.decoded(as: S3UploadParams.self)

        // Step 2: Upload file to S3
        try await withCheckedThrowingContinuation { continuation in
            self.s3Client.upload(url: uploadParams.url, fields: uploadParams.fields, data: data) { s3Result in
                switch s3Result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        // Step 3: Create audio record
        return try await createAudio(
            s3Key: uploadParams.fields["key"] ?? "",
            filename: filename,
            source: source,
            target: target,
            options: options
        )
    }

    /// Get the status of an audio translation
    /// - Parameters:
    ///   - id: Audio ID
    /// - Returns: audio information
    public func status(id: String) async throws -> Audio {
        let result = try await client.get(path: "/v2/audio/\(id)")
        return try result.decoded(as: Audio.self)
    }

    /// Download a translated audio file
    /// - Parameters:
    ///   - id: Audio ID
    /// - Returns: downloaded audio data
    public func download(id: String) async throws -> Data {
        // Get download URL
        let response = try await client.get(path: "/v2/audio/\(id)/download-url")
        let downloadResponse = try response.decoded(as: AudioDownloadUrlResponse.self)

        // Download from S3
        return try await withCheckedThrowingContinuation { continuation in
            self.s3Client.download(url: downloadResponse.url) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Polls the audio status until it reaches TRANSLATED or ERROR
    /// - Parameters:
    ///   - id: Audio ID
    ///   - maxWaitTime: Maximum time to wait (defaults to 15 minutes)
    /// - Returns: final Audio
    private func waitForCompletion(
        id: String,
        maxWaitTime: TimeInterval = 900
    ) async throws -> Audio {
        return try await Poller.poll(
            initial: try await status(id: id),
            interval: pollingInterval,
            maxTime: maxWaitTime,
            next: { [weak self] _ in
                guard let self = self else {
                    throw LaraApiConnectionError("AudioTranslator client deallocated during polling")
                }
                let audio = try await self.status(id: id)

                if audio.status == .error {
                    let errorMessage = audio.errorReason ?? "Audio translation failed"
                    throw LaraApiError(
                        statusCode: 500,
                        type: "AudioTranslationError",
                        message: errorMessage
                    )
                }

                return audio
            },
            isFinished: { $0.status == .translated }
        )
    }

    /// Upload and translate an audio file in one operation
    /// Internally composes: upload -> waitForCompletion -> download
    public func translate(
        data: Data,
        filename: String,
        source: String? = nil,
        target: String,
        options: AudioUploadOptions? = nil
    ) async throws -> Data {
        // Upload the audio
        let audio = try await upload(data: data, filename: filename, source: source, target: target, options: options)

        // Wait for completion
        _ = try await waitForCompletion(id: audio.id)

        // Then download
        return try await download(id: audio.id)
    }

    // MARK: - Private Helper Methods

    private func createAudio(
        s3Key: String,
        filename: String,
        source: String?,
        target: String,
        options: AudioUploadOptions?
    ) async throws -> Audio {
        var params: [String: Any] = [
            "target": target,
            "s3key": s3Key
        ]

        if let source = source {
            params["source"] = source
        }

        if let options = options {
            params.merge(options.toParams()) { (_, new) in new }
        }

        var headers: [String: String] = [:]
        if let noTrace = options?.noTrace, noTrace == true {
            headers["X-No-Trace"] = "true"
        }

        let result = try await client.post(path: "/v2/audio/translate", params: params, headers: headers)
        return try result.decoded(as: Audio.self)
    }
}