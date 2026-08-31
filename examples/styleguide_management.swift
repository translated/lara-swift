import Lara
import Foundation

// Complete styleguide management examples for the Lara Swift SDK
//
// This example demonstrates:
// - Create, list, get, update, delete styleguides
// - Sharing a styleguide with the account or a group (add, rename, list, revoke)

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"

    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    print("📘 Styleguides require a specific subscription plan.")
    print("   If you encounter errors, please check your subscription level.\n")

    var styleguideId: String?

    do {
        print("=== Basic Styleguide Management ===")
        let initialContent = "Use a formal tone. Prefer British English spelling. Avoid contractions."
        let styleguide = try await lara.styleguides.create(name: "MyDemoStyleguide", content: initialContent)
        print("✅ Created styleguide: \(styleguide.name) (ID: \(styleguide.id))")
        styleguideId = styleguide.id

        let styleguides = try await lara.styleguides.list()
        print("📝 Total styleguides: \(styleguides.count)")
        print()

        print("=== Styleguide Operations ===")
        if let retrieved = try await lara.styleguides.get(id: styleguide.id) {
            print("📖 Styleguide: \(retrieved.name) (Owner: \(retrieved.ownerId))")
            print("   Personal: \(retrieved.isPersonal)")
            print("   Created at: \(retrieved.createdAt)")
            if let content = retrieved.content {
                let preview = String(content.prefix(80))
                print("   Content preview: \(preview)...")
            }
        }
        print()

        print("=== Update Styleguide ===")
        let renamed = try await lara.styleguides.update(id: styleguide.id, name: "UpdatedDemoStyleguide")
        print("📝 Updated name: '\(styleguide.name)' -> '\(renamed.name)'")

        let updatedContent = "Use a casual tone. Prefer American English spelling. Contractions are welcome."
        let contentUpdated = try await lara.styleguides.update(id: styleguide.id, content: updatedContent)
        print("📝 Updated content for styleguide: \(contentUpdated.name)")
        if let content = contentUpdated.content {
            let preview = String(content.prefix(80))
            print("   New content preview: \(preview)...")
        }

        let fullyUpdated = try await lara.styleguides.update(
            id: styleguide.id,
            name: "FinalDemoStyleguide",
            content: "Use clear and concise language. Avoid jargon."
        )
        print("📝 Updated name and content: \(fullyUpdated.name)")
        print()

        print("=== Get Non-Existent Styleguide ===")
        let missing = try await lara.styleguides.get(id: "non-existent-id")
        if missing == nil {
            print("ℹ️  Styleguide not found (returned nil as expected)")
        }
        print()

        // Example 5: Styleguide sharing
        // Sharing requires a multi-user account and the appropriate role (account owner for
        // account-wide shares, owner/admin for group shares). Each call returns the shared
        // styleguide, whose `name` reflects the shared copy's name and `sharedAt` the share time.
        print("=== Styleguide Sharing ===")
        do {
            // Share with the whole account/team (the optional name: names the shared copy)
            let teamShare = try await lara.styleguides.addAccountShare(id: styleguide.id, name: "Shared with the team")
            print("🤝 Shared with the account as: '\(teamShare.name)' (shared at \(teamShare.sharedAt))")

            // Rename the account/team share
            let renamedTeamShare = try await lara.styleguides.renameAccountShare(id: styleguide.id, name: "Team styleguide")
            print("📝 Renamed account share to: '\(renamedTeamShare.name)'")

            // List every share visible to the caller: the account share, group shares and user shares
            let shares = try await lara.styleguides.getShares(id: styleguide.id)
            if let account = shares.account {
                print("👥 Account share '\(account.shareName)' (\(account.permissions.rawValue))")
            }
            for group in shares.groups {
                print("👥 Group \(group.name): '\(group.shareName)' (\(group.permissions.rawValue))")
            }
            for user in shares.users {
                print("👤 User \(user.name): '\(user.shareName)' (\(user.permissions.rawValue))")
            }

            // Revoke the account/team share
            _ = try await lara.styleguides.revokeAccountShare(id: styleguide.id)
            print("🚫 Revoked the account share")

            // Group shares work the same way, addressed by a group ID (grp_...)
            if let groupId = ProcessInfo.processInfo.environment["LARA_GROUP_ID"] {
                let groupShare = try await lara.styleguides.addGroupShare(id: styleguide.id, groupId: groupId, name: "Shared with the group")
                print("🤝 Shared with group \(groupId) as: '\(groupShare.name)'")

                _ = try await lara.styleguides.renameGroupShare(id: styleguide.id, groupId: groupId, name: "Marketing group")
                print("📝 Renamed the group share")

                _ = try await lara.styleguides.revokeGroupShare(id: styleguide.id, groupId: groupId)
                print("🚫 Revoked the group share")
            } else {
                print("Set LARA_GROUP_ID to try the group sharing methods.")
            }
            print()
        } catch {
            print("Error sharing styleguide: \(error)")
        }

    } catch {
        print("Error during styleguide management: \(error)")
        return
    }

    print("=== Cleanup ===")
    if let styleguideId {
        do {
            _ = try await lara.styleguides.delete(id: styleguideId)
            print("🗑️  Deleted styleguide with ID: \(styleguideId)")
        } catch {
            print("Error deleting styleguide: \(error)")
        }
    }

    print("\n🎉 Styleguide management examples completed!")
}

Task {
    await main()
}
