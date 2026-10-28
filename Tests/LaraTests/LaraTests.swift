import Foundation
import Testing
@testable import Lara

@Test
func glossaryDecodesRequiredSharedAt() throws {
    let json = #"{"id":"gls_1","created_at":"2026-08-28T10:00:00.000Z","updated_at":"2026-08-28T10:00:00.000Z","shared_at":"2026-08-28T10:00:00.000Z","name":"Terms","owner_id":"acc_1"}"#
    let glossary = try APIJSONDecoder.decode(Glossary.self, from: Data(json.utf8))

    #expect(glossary.sharedAt == glossary.createdAt)
}

@Test
func styleguideDecodesRequiredSharedAt() throws {
    let json = #"{"id":"stg_1","name":"Editorial","owner_id":"acc_1","created_at":"2026-08-28T10:00:00.000Z","updated_at":"2026-08-28T10:00:00.000Z","shared_at":"2026-08-28T10:00:00.000Z"}"#
    let styleguide = try APIJSONDecoder.decode(Styleguide.self, from: Data(json.utf8))

    #expect(styleguide.sharedAt == styleguide.createdAt)
}

@Test
func sharesPreserveUnknownPermissionMask() throws {
    let json = """
    {
        "glossary": {
            "id": "gls_1",
            "created_at": "2026-08-28T10:00:00.000Z",
            "updated_at": "2026-08-28T10:00:00.000Z",
            "shared_at": "2026-08-28T10:00:00.000Z",
            "name": "Terms",
            "owner_id": "acc_1"
        },
        "account": {
            "id": "acc_1",
            "name": "Example account",
            "share_name": "Team share",
            "shared_at": "2026-08-28T10:00:00.000Z",
            "permission_mask": "future-mask"
        },
        "groups": [],
        "users": []
    }
    """

    let shares = try APIJSONDecoder.decode(GlossaryShares.self, from: Data(json.utf8))

    #expect(shares.account?.permissionMask.rawValue == "future-mask")
}

@Test
func imageContextSerializesObjectArrayEmptyAndOmitted() throws {
    let image = ImageContext(url: "https://example.com/storefront.png")
    let single = TranslateOptions(reasoning: true, imageContext: .single(image)).toParams()
    let singleJSON = try JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: single)) as! [String: Any]
    #expect((singleJSON["image_context"] as? [String: String])?["url"] == image.url)
    #expect(singleJSON["reasoning"] as? Bool == true)

    let inline = ImageContext(url: "data:image/png;base64,aW1hZ2U=")
    let multiple = TranslateOptions(reasoning: true, imageContext: .multiple([inline])).toParams()
    let multipleJSON = try JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: multiple)) as! [String: Any]
    #expect((multipleJSON["image_context"] as? [[String: String]])?.first?["url"] == inline.url)
    #expect((TranslateOptions(imageContext: .multiple([])).toParams()["image_context"] as? [[String: String]])?.isEmpty == true)
    #expect(TranslateOptions().toParams()["image_context"] == nil)
}

@Test
func imageContextWarningsDecodeRecoveryAndFallback() throws {
    for applied in [true, false] {
        let json = """
        {"content_type":"text/plain","source_language":"en-US","translation":"Aperto",
         "warnings":{
           "reasoning":{"applied":\(applied),"error":\(applied ? "null" : #"{"status_code":503,"message":"Unavailable"}"#),
             "warnings":[{"code":"image_context_unavailable","message":"Image unavailable"}]},
           "references":{"applied":"partial","error":{"status_code":503,"message":"Unavailable"}},
           "prosa":{"applied":false,"error":{"status_code":500,"message":"Failed"}}}}
        """
        let result = try APIJSONDecoder.decode(TextResult.self, from: Data(json.utf8))
        #expect(result.warnings?.reasoning?.applied == applied)
        #expect(result.warnings?.reasoning?.error?.statusCode == (applied ? nil : 503))
        #expect(result.warnings?.reasoning?.warnings.first?.code == "image_context_unavailable")
        #expect(result.warnings?.references?.applied == .partial)
        #expect(result.warnings?.references?.error.statusCode == 503)
        #expect(result.warnings?.prosa?.applied == false)
        #expect(result.warnings?.prosa?.error.statusCode == 500)
        let roundTrip = try APIJSONDecoder.decode(TextResult.self, from: JSONEncoder().encode(result))
        #expect(roundTrip.warnings?.reasoning?.warnings.first?.message == "Image unavailable")
    }
}

@Test
func textOnlyResultsAndFailuresWithoutImageWarningsDecode() throws {
    let plain = #"{"content_type":"text/plain","source_language":"en-US","translation":"Aperto"}"#
    #expect(try APIJSONDecoder.decode(TextResult.self, from: Data(plain.utf8)).warnings == nil)
    let json = """
    {"reasoning":{"applied":false,"error":{"status_code":500,"message":"Failed"}},
     "references":{"applied":false,"error":{"status_code":500,"message":"Failed"}}}
    """
    let warnings = try APIJSONDecoder.decode(TextWarnings.self, from: Data(json.utf8))
    #expect(warnings.reasoning?.warnings.isEmpty == true)
    #expect(warnings.references?.applied == .notApplied)
}

@Test(arguments: ["reasoning", "references", "prosa"])
func successfulTranslationDecodesAPIFailureWarning(stage: String) throws {
    let json = """
    {"content_type":"text/plain","source_language":"en","translation":"Ciao",
     "warnings":{"\(stage)":{"applied":false,"error":{"status_code":502,"message":"Unavailable"}}}}
    """
    let httpResponse = try #require(HTTPURLResponse(
        url: URL(string: "https://api.laratranslate.com/v2/translate")!,
        statusCode: 200, httpVersion: nil, headerFields: nil))
    let response = ClientResponse(
        data: Data(json.utf8), httpResponse: httpResponse, decoder: APIJSONDecoder.decoder())

    // Use the same response decoding path as Translator.translateAny().
    let result = try response.decoded(as: TextResult.self)
    #expect(try result.translation.getTranslation() == "Ciao")
    let error: IntelligenceError?
    switch stage {
    case "reasoning": error = result.warnings?.reasoning?.error
    case "references": error = result.warnings?.references?.error
    default: error = result.warnings?.prosa?.error
    }
    #expect(error?.statusCode == 502)
    #expect(error?.message == "Unavailable")

    let encoded = try JSONEncoder().encode(result)
    let body = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    let warnings = try #require(body["warnings"] as? [String: [String: Any]])
    let encodedError = try #require(warnings[stage]?["error"] as? [String: Any])
    #expect(encodedError["status_code"] as? Int == 502)
    #expect(encodedError["statusCode"] == nil)
}

@Test(arguments: ["low", "medium", "high"])
func reasoningEffortParameters(effort: String) throws {
    let level = try #require(ReasoningEffort(rawValue: effort))
    let params = TranslateOptions(reasoning: true, effort: level).toParams()
    let data = try JSONSerialization.data(withJSONObject: params)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(json["effort"] as? String == effort)
    #expect(json["reasoning"] as? Bool == true)
}

@Test
func omittedReasoningEffort() {
    #expect(TranslateOptions().toParams()["effort"] == nil)
    #expect(TranslateOptions(reasoning: true).toParams()["effort"] == nil)
}
