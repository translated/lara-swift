import Foundation

public class Translator {

    private let client: Client
    public let memories: Memories
    public let glossaries: Glossaries
    public let documents: Documents

    // MARK: - Init

    /// Init translator
    public init(credentials: Credentials, clientOptions: ClientOptions = ClientOptions()) {
        self.client = Client(credentials: credentials, options: clientOptions)

        self.memories = Memories(client: client)
        self.glossaries = Glossaries(client: client)
        self.documents = Documents(client: client)
    }

    /// Set an extra header for all requests
    public func setExtraHeader(name: String, value: String) {
        client.setExtraHeader(name: name, value: value)
    }

    // MARK: - Text translation

    /// Translate single sentence
    /// - Parameters:
    ///   - text: source string
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    /// - Returns: translation result
    public func translate(text: String, source: String? = nil, target: String, options: TranslateOptions?) async throws -> TextResult {
        try await translateAny(text: text, source: source, target: target, options: options)
    }

    /// Translate an array of sentences
    /// - Parameters:
    ///   - text: array of source strings
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    /// - Returns: translation result
    public func translate(text: [String], source: String? = nil, target: String, options: TranslateOptions?) async throws -> TextResult {
        try await translateAny(text: text, source: source, target: target, options: options)
    }

    /// Translate an array of text blocks
    /// - Parameters:
    ///   - text: array of text blocks
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    /// - Returns: translation result
    public func translate(text: [TextBlock], source: String? = nil, target: String, options: TranslateOptions?) async throws -> TextResult {
        try await translateAny(text: text, source: source, target: target, options: options)
    }
    
    /// Translate
    /// - Parameters:
    ///   - text: source
    ///   - source: source language (optional)
    ///   - target: target language
    ///   - options: translation options
    /// - Returns: translation result
    private func translateAny(text: Any, source: String? = nil, target: String, options: TranslateOptions?) async throws -> TextResult {

        var params: [String: Any]

        if let textBlocks = text as? [TextBlock] {
            let textBlocksJSON = textBlocks.map { $0.apiRepresentation }

            params = [
                "target": target,
                "q": textBlocksJSON
            ]
        } else {
            params = [
                "target": target,
                "q": text
            ]
        }

        if let sourceLang = source {
            params["source"] = sourceLang
        }

        let optionsParameters = options?.toParams() ?? [:]
        params.merge(optionsParameters) {(_, new) in new}

        var headers = options?.headers ?? [:]
        if let noTrace = options?.noTrace, noTrace == true {
            headers["X-No-Trace"] = "true"
        }

        let result = try await client.post(path: "/translate", params: params, headers: headers)
        return try APIResponseHandler.handleAPIResponse(result)
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

        let result = try await client.post(path: "/detect", params: params)
        return try APIResponseHandler.handleAPIResponse(result)
    }

    // MARK - Supported languages
    public func getLanguages() async throws -> [String] {
        let result = try await client.get(path: "/languages")
        return try APIResponseHandler.handleAPIResponse(result)
    }
}
