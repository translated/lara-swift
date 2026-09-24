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

    /// Renders supplied translations onto the original image without translating again.
    /// Overlay and inpainting require bbox, linesBboxes, textInfo, and alignment on every
    /// paragraph. Generative models accept text-only paragraphs or complete layout.
    /// An omitted model defaults to generative_fast.
    public func renderTranslated(
        file: MultipartFile,
        source: String? = nil,
        target: String,
        paragraphs: [ImageParagraph],
        model: ImageTranslationModel? = nil,
        noTrace: Bool = false
    ) async throws -> Data {
        // Match metadata is not part of the rendering endpoint.
        let renderParagraphs = paragraphs.map {
            ImageParagraph(text: $0.text, translation: $0.translation,
                           bbox: $0.bbox, linesBboxes: $0.linesBboxes,
                           textInfo: $0.textInfo, alignment: $0.alignment)
        }
        let paragraphsData = try JSONEncoder().encode(renderParagraphs)
        var params: [String: Any] = [
            "target": target,
            "paragraphs": String(decoding: paragraphsData, as: UTF8.self)
        ]
        if let source = source { params["source"] = source }
        if let model = model { params["model"] = model.rawValue }
        let headers = noTrace ? ["X-No-Trace": "true"] : [:]
        let response = try await client.post(
            path: "/v2/images/render-translated",
            params: params,
            files: ["image": file.data],
            filenames: ["image": file.filename],
            headers: headers
        )
        return response.data
    }

    /// Convenience method to render supplied translations from image Data.
    public func renderTranslated(
        imageData: Data,
        filename: String,
        source: String? = nil,
        target: String,
        paragraphs: [ImageParagraph],
        model: ImageTranslationModel? = nil,
        noTrace: Bool = false
    ) async throws -> Data {
        let file = MultipartFile(filename: filename, data: imageData)
        return try await renderTranslated(file: file, source: source, target: target,
                                          paragraphs: paragraphs, model: model, noTrace: noTrace)
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
