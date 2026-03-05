import Foundation

public class ImageTranslator {
    private let client: Client

    public init(client: Client) {
        self.client = client
    }

    /// Translate an image and return the translated image
    /// - Parameters:
    ///   - file: The image file to translate (as MultipartFile)
    ///   - source: Source language (optional)
    ///   - target: Target language
    ///   - options: Translation options
    /// - Returns: Data containing the translated image
    public func translate(
        file: MultipartFile,
        source: String? = nil,
        target: String,
        options: ImageTranslationOptions? = nil
    ) async throws -> Data {
        var headers: [String: String] = [:]

        if options?.noTrace == true {
            headers["X-No-Trace"] = "true"
        }

        var params: [String: Any] = [
            "target": target
        ]

        if let source = source {
            params["source"] = source
        }

        if let options = options {
            let optionParams = options.toParams()
            for (key, value) in optionParams {
                params[key] = value
            }
        }

        let response = try await client.post(
            path: "/v2/images/translate",
            params: params,
            files: ["image": file.data],
            filenames: ["image": file.filename],
            headers: headers
        )

        return response.data
    }

    /// Translate an image and return text results with metadata
    /// - Parameters:
    ///   - file: The image file to translate (as MultipartFile)
    ///   - source: Source language (optional)
    ///   - target: Target language
    ///   - options: Translation options
    /// - Returns: ImageTextResult containing the translated text and metadata
    public func translateText(
        file: MultipartFile,
        source: String? = nil,
        target: String,
        options: ImageTextTranslationOptions? = nil
    ) async throws -> ImageTextResult {
        var headers: [String: String] = [:]

        if options?.noTrace == true {
            headers["X-No-Trace"] = "true"
        }

        var params: [String: Any] = [
            "target": target
        ]

        if let source = source {
            params["source"] = source
        }

        if let options = options {
            let optionParams = options.toParams()
            for (key, value) in optionParams {
                params[key] = value
            }
        }

        let response = try await client.post(
            path: "/v2/images/translate-text",
            params: params,
            files: ["image": file.data],
            filenames: ["image": file.filename],
            headers: headers
        )

        return try response.decoded(as: ImageTextResult.self)
    }

    /// Convenience method to translate an image from Data
    /// - Parameters:
    ///   - imageData: Raw image data
    ///   - filename: Original filename (used for MIME type detection)
    ///   - source: Source language (optional)
    ///   - target: Target language
    ///   - options: Translation options including text removal type
    /// - Returns: Data containing the translated image
    public func translate(
        imageData: Data,
        filename: String,
        source: String? = nil,
        target: String,
        options: ImageTranslationOptions? = nil
    ) async throws -> Data {
        let file = MultipartFile(filename: filename, data: imageData)
        return try await translate(file: file, source: source, target: target, options: options)
    }

    /// Convenience method to translate text from image Data
    /// - Parameters:
    ///   - imageData: Raw image data
    ///   - filename: Original filename (used for MIME type detection)
    ///   - source: Source language (optional)
    ///   - target: Target language
    ///   - options: Translation options
    /// - Returns: ImageTextResult containing the translated text and metadata
    public func translateText(
        imageData: Data,
        filename: String,
        source: String? = nil,
        target: String,
        options: ImageTextTranslationOptions? = nil
    ) async throws -> ImageTextResult {
        let file = MultipartFile(filename: filename, data: imageData)
        return try await translateText(file: file, source: source, target: target, options: options)
    }
}
