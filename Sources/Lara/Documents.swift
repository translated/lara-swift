import Foundation

/// Documents class providing methods for document translation operations
public class Documents {

    private let client: Client
    private let s3Client: S3Client
    private let pollingInterval: TimeInterval = 2.0 // seconds

    /// Initialize Documents with a client
    /// - Parameters:
    ///   - client: The Lara API client
    public init(client: Client) {
        self.client = client
        self.s3Client = S3Client()
    }


    /// Upload a document for translation
    /// - Parameters:
    ///   - data: The document data to upload
    ///   - filename: Name of the document file
    ///   - source: Source language (optional, auto-detected if nil)
    ///   - target: Target language for translation
    ///   - options: Upload options (optional)
    /// - Returns: document information
    public func upload(
        data: Data,
        filename: String,
        source: String? = nil,
        target: String,
        options: DocumentUploadOptions? = nil
    ) async throws -> Document {
        // Step 1: Get upload URL and S3 parameters
        let uploadUrlParams: [String: Any] = ["filename": filename]

        let response = try await client.get(path: "/documents/upload-url", params: uploadUrlParams)
        let api = try APIJSONDecoder.decode(ApiResponse<S3UploadParams>.self, from: response.data)
        let uploadParams = api.content

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

        // Step 3: Create document record
        return try await createDocument(
            s3Key: uploadParams.fields["key"] ?? "",
            filename: filename,
            source: source,
            target: target,
            options: options
        )
    }

    /// Get the status of a document
    /// - Parameters:
    ///   - id: Document ID
    /// - Returns: document information
    public func status(id: String) async throws -> Document {
        let result = try await client.get(path: "/documents/\(id)")
        return try APIResponseHandler.handleAPIResponse(result)
    }

    /// Download a translated document
    /// - Parameters:
    ///   - id: Document ID
    ///   - options: Download options (optional)
    /// - Returns: downloaded document data
    public func download(
        id: String,
        options: DocumentDownloadOptions? = nil
    ) async throws -> Data {
        // Get download URL
        let params = options?.toParams() ?? [:]

        let response = try await client.get(path: "/documents/\(id)/download-url", params: params)
        let api = try APIJSONDecoder.decode(ApiResponse<DownloadUrlResponse>.self, from: response.data)

        // Download from S3
        return try await withCheckedThrowingContinuation { continuation in
            self.s3Client.download(url: api.content.url) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Polls the document status until it reaches TRANSLATED or ERROR
    /// - Parameters:
    ///   - id: Document ID
    ///   - maxWaitTime: Maximum time to wait (defaults to 15 minutes)
    /// - Returns: final Document
    private func waitForCompletion(
        id: String,
        maxWaitTime: TimeInterval = 900
    ) async throws -> Document {
        return try await Poller.poll(
            initial: try await status(id: id),
            interval: pollingInterval,
            maxTime: maxWaitTime,
            next: { [weak self] _ in
                guard let self = self else {
                    throw LaraApiConnectionError("Documents client deallocated during polling")
                }
                let document = try await self.status(id: id)

                if document.status == .error {
                    let errorMessage = document.errorReason ?? "Document translation failed"
                    throw LaraApiError(
                        statusCode: 500,
                        type: "DocumentTranslationError",
                        message: errorMessage
                    )
                }

                return document
            },
            isFinished: { $0.status == .translated }
        )
    }

    /// Upload and translate a document in one operation
    /// Internally composes: upload -> waitForCompletion -> download
    public func translate(
        data: Data,
        filename: String,
        source: String? = nil,
        target: String,
        options: DocumentTranslateOptions? = nil
    ) async throws -> Data {

        let uploadOptions = DocumentUploadOptions(
            adaptTo: options?.adaptTo,
            glossaries: options?.glossaries,
            noTrace: options?.noTrace,
            style: options?.style,
            password: options?.password,
            extractionParams: options?.extractionParams
        )

        // Upload the document
        let document = try await upload(data: data, filename: filename, source: source, target: target, options: uploadOptions)

        // Wait for completion
        _ = try await waitForCompletion(id: document.id)

        // Then download
        let downloadOptions = options?.outputFormat != nil ? DocumentDownloadOptions(outputFormat: options?.outputFormat) : nil
        return try await download(id: document.id, options: downloadOptions)
    }

    // MARK: - Private Helper Methods

    private func createDocument(
        s3Key: String,
        filename: String,
        source: String?,
        target: String,
        options: DocumentUploadOptions?
    ) async throws -> Document {
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

        let result = try await client.post(path: "/documents", params: params, headers: headers)
        return try APIResponseHandler.handleAPIResponse(result)
    }
}
