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
