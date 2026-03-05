import Foundation

public class Translator {

    private let laraClient: Client
    public let memories: Memories
    public let glossaries: Glossaries
    public let documents: Documents
    public let images: ImageTranslator
    public let audio: AudioTranslator

    // MARK: - Init

    /// Init translator
    public init(accessKey: AccessKey, clientOptions: ClientOptions = ClientOptions()) {
        self.laraClient = Client(accessKey: accessKey, options: clientOptions)
        self.memories = Memories(client: laraClient)
        self.glossaries = Glossaries(client: laraClient)
        self.documents = Documents(client: laraClient)
        self.images = ImageTranslator(client: laraClient)
        self.audio = AudioTranslator(client: laraClient)
    }

    public init(authToken: AuthToken, clientOptions: ClientOptions = ClientOptions()) {
        self.laraClient = Client(authToken: authToken, options: clientOptions)
        self.memories = Memories(client: laraClient)
        self.glossaries = Glossaries(client: laraClient)
        self.documents = Documents(client: laraClient)
        self.images = ImageTranslator(client: laraClient)
        self.audio = AudioTranslator(client: laraClient)
    }

    @available(*, deprecated, message: "Use init(accessKey:) with AccessKey instead")
    public convenience init(credentials: Credentials, clientOptions: ClientOptions = ClientOptions()) {
        self.init(accessKey: credentials, clientOptions: clientOptions)
    }

    /// Set an extra header for all requests
    public func setExtraHeader(name: String, value: String) {
        laraClient.setExtraHeader(name: name, value: value)
    }

    // MARK: - Text translation

    /// Translate single sentence
    /// - Parameters:
    ///   - text: source string
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    ///   - callback: callback for streaming partial results (requires reasoning=true)
    /// - Returns: translation result
    public func translate(text: String, source: String? = nil, target: String, options: TranslateOptions?, callback: ((Any) -> Void)? = nil) async throws -> TextResult {
        try await translateAny(text: text, source: source, target: target, options: options, callback: callback)
    }

    /// Translate an array of sentences
    /// - Parameters:
    ///   - text: array of source strings
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    ///   - callback: callback for streaming partial results (requires reasoning=true)
    /// - Returns: translation result
    public func translate(text: [String], source: String? = nil, target: String, options: TranslateOptions?, callback: ((Any) -> Void)? = nil) async throws -> TextResult {
        try await translateAny(text: text, source: source, target: target, options: options, callback: callback)
    }

    /// Translate an array of text blocks
    /// - Parameters:
    ///   - text: array of text blocks
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    ///   - callback: callback for streaming partial results (requires reasoning=true)
    /// - Returns: translation result
    public func translate(text: [TextBlock], source: String? = nil, target: String, options: TranslateOptions?, callback: ((Any) -> Void)? = nil) async throws -> TextResult {
        try await translateAny(text: text, source: source, target: target, options: options, callback: callback)
    }
    
    /// Translate
    /// - Parameters:
    ///   - text: source
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    ///   - callback: callback for streaming partial results
    /// - Returns: translation result
    private func translateAny(text: Any, source: String? = nil, target: String, options: TranslateOptions?, callback: ((Any) -> Void)? = nil) async throws -> TextResult {

        var q: Any = text

        if let textBlocks = text as? [TextBlock] {
            q = textBlocks.map { block in
                ["text": block.text, "translatable": block.translatable]
            }
        }

        var params: [String: Any] = [
            "target": target,
            "q": q
        ]

        if let sourceLang = source {
            params["source"] = sourceLang
        }

        var headers = options?.headers ?? [:]
        if let noTrace = options?.noTrace, noTrace == true {
            headers["X-No-Trace"] = "true"
        }

        if let options = options {
            let optionParams = options.toParams()
            for (key, value) in optionParams {
                params[key] = value
            }
        }

        let response = try await laraClient.postStream(path: "/translate", params: params, headers: headers, callback: callback)
        return try response.decoded(as: TextResult.self)
    }

    // MARK - Supported languages
    public func getLanguages() async throws -> [String] {
        let response = try await laraClient.get(path: "/v2/languages")
        return try response.decoded(as: [String].self)
    }

    // MARK: - Language Detection

    public func detect(text: String, hint: String? = nil, passlist: [String]? = nil) async throws -> DetectResult {
        try await detectAny(text: text, hint: hint, passlist: passlist)
    }

    public func detect(text: [String], hint: String? = nil, passlist: [String]? = nil) async throws -> DetectResult {
        try await detectAny(text: text, hint: hint, passlist: passlist)
    }

    private func detectAny(text: Any, hint: String? = nil, passlist: [String]? = nil) async throws -> DetectResult {
        var params: [String: Any] = [
            "q": text
        ]

        if let hint = hint {
            params["hint"] = hint
        }

        if let passlist = passlist, !passlist.isEmpty {
            params["passlist"] = passlist
        }

        let response = try await laraClient.post(path: "/v2/detect", params: params)
        return try response.decoded(as: DetectResult.self)
    }
}
