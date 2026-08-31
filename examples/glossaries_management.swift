import Lara
import Foundation

// Complete glossary management examples for the Lara Swift SDK
//
// This example demonstrates:
// - Create, list, update, delete glossaries
// - Individual term management (add/remove terms)
// - CSV import with status monitoring
// - Glossary export and async export
// - Glossary terms count
// - Import status checking
// - Sharing a glossary with the account or a group (add, rename, list, revoke)

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"

    // Set your credentials here
    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    print("🗒️  Glossaries require a specific subscription plan.")
    print("   If you encounter errors, please check your subscription level.\n")

    do {
        // Example 1: Basic glossary management
        print("=== Basic Glossary Management ===")
        let glossary = try await lara.glossaries.create(name: "MyDemoGlossary")
        print("✅ Created glossary: \(glossary.name) (ID: \(glossary.id))")

        let glossaryId = glossary.id

        // List all glossaries
        let glossaries = try await lara.glossaries.list()
        print("📝 Total glossaries: \(glossaries.count)")
        print()

        // Example 2: Glossary operations
        print("=== Glossary Operations ===")
        // Get glossary details
        let retrievedGlossary = try await lara.glossaries.get(id: glossaryId)
        print("📖 Glossary: \(retrievedGlossary.name) (Owner: \(retrievedGlossary.ownerId ?? "Unknown"))")

        // Get glossary terms count
        let counts = try await lara.glossaries.counts(id: glossaryId)
        if let unidirectional = counts.unidirectional, !unidirectional.isEmpty {
            print("📊 Glossary terms count:")
            unidirectional.forEach { lang, count in
                print("   \(lang): \(count) entries")
            }
        }

        // Update glossary
        let updatedGlossary = try await lara.glossaries.update(id: glossaryId, name: "UpdatedDemoGlossary")
        print("📝 Updated name: '\(glossaryId)' -> '\(updatedGlossary.name)'")
        print()

        // Example 3: Term management
        print("=== Term Management ===")

        // Add (or replace) individual terms to glossary
        let terms = [
            ["language": "fr-FR", "value": "Bonjour"],
            ["language": "es-ES", "value": "Hola"]
        ]
        _ = try await lara.glossaries.addOrReplaceEntry(glossaryId: glossaryId, terms: terms, guid: nil)
        print("✅ Terms added successfully to glossary")
        print()

        // Remove a specific term from glossary
        let termToRemove = ["language": "fr-FR", "value": "Bonjour"]
        _ = try await lara.glossaries.deleteEntry(glossaryId: glossaryId, term: termToRemove, guid: nil)
        print("✅ Term removed successfully from glossary")
        print()

        // Example 4: CSV import functionality
        print("=== CSV Import Functionality ===")

        // Replace with your actual CSV file path
        let csvFilePath = "sample_glossary.csv"  // Create this file with your glossary data

        if FileManager.default.fileExists(atPath: csvFilePath) {
            print("Importing CSV file: \(FileManager.default.displayName(atPath: csvFilePath))")

            let csvData = try Data(contentsOf: URL(fileURLWithPath: csvFilePath))
            let glossaryImport = try await lara.glossaries.importCsv(id: glossaryId, csv: csvData, gzip: false)
            print("Import started with ID: \(glossaryImport.id)")
            print("Initial progress: \(Int(glossaryImport.progress * 100))%")

            // Check import status manually
            print("Checking import status...")
            let importStatus = try await lara.glossaries.getImportStatus(id: glossaryImport.id)
            print("Current progress: \(Int(importStatus.progress * 100))%")

            // Wait for import to complete
            let completedImport = try await lara.glossaries.waitForImport(glossaryImport)
            print("✅ Import completed!")
            print("Final progress: \(Int(completedImport.progress * 100))%")
        } else {
            print("CSV file not found: \(csvFilePath)")
        }
        print()

        // Example 5: CSV import with a callback URL (async notification when import completes)
        print("=== CSV Import with Callback URL ===")
        if FileManager.default.fileExists(atPath: csvFilePath) {
            let callbackUrl = "https://your-server.example.com/lara/import-callback" // Replace with your endpoint
            let csvData = try Data(contentsOf: URL(fileURLWithPath: csvFilePath))
            let importWithCallback = try await lara.glossaries.importCsv(
                id: glossaryId,
                csv: csvData,
                gzip: false,
                callbackUrl: callbackUrl
            )
            print("Import started with ID: \(importWithCallback.id) (callback: \(callbackUrl))")

            // You can also combine content type, gzip, and callbackUrl:
            // let importWithCallback = try await lara.glossaries.importCsv(
            //     id: glossaryId,
            //     csv: csvData,
            //     contentType: .csvTableUni,
            //     gzip: true,
            //     callbackUrl: callbackUrl
            // )
            print()
        } else {
            print("CSV file not found: \(csvFilePath)\n")
        }

        // Example 6: Export functionality
        print("=== Export Functionality ===")

        // Export as CSV table unidirectional format
        print("📤 Exporting as CSV table unidirectional...")
        let csvString = try await lara.glossaries.export(id: glossaryId, contentType: .csvTableUni, source: "en-US")
        print("✅ CSV unidirectional export successful (\(csvString.count) bytes)")

        // Save sample export to file - replace with your desired output path
        let exportFilePath = "exported_glossary.csv"  // Replace with actual path
        try csvString.write(to: URL(fileURLWithPath: exportFilePath), atomically: true, encoding: .utf8)
        print("💾 Sample export saved to: \(FileManager.default.displayName(atPath: exportFilePath))")

        // Async export - returns a jobId; the result is delivered to your callback URL when ready
        print("📤 Starting async export...")
        let exportJob = try await lara.glossaries.exportAsync(
            id: glossaryId,
            callbackUrl: "https://your-server.example.com/lara/export-callback",  // Replace with your actual callback URL
            contentType: .csvTableUni,
            source: "en-US"
        )
        print("✅ Async export started (job ID: \(exportJob.jobId))")
        print("   The export result will be delivered to your callback URL when ready.")
        print()

        // Example 7: Glossary Terms Count
        print("=== Glossary Terms Count ===")
        let finalCounts = try await lara.glossaries.counts(id: glossaryId)
        print("📊 Detailed glossary terms count:")

        if let unidirectional = finalCounts.unidirectional, !unidirectional.isEmpty {
            print("   Unidirectional entries by language pair:")
            unidirectional.forEach { langPair, count in
                print("     \(langPair): \(count) terms")
            }
        } else {
            print("   No unidirectional entries found")
        }

        let totalEntries = finalCounts.unidirectional?.values.reduce(0, +) ?? 0
        print("   Total entries: \(totalEntries)")

        // Example 8: Glossary sharing
        // Sharing requires a multi-user account and the appropriate role (account owner for
        // account-wide shares, owner/admin for group shares). Each call returns the shared
        // glossary, whose `name` reflects the shared copy's name and `sharedAt` the share time.
        print("=== Glossary Sharing ===")
        do {
            // Share with the whole account/team (the optional name: names the shared copy)
            let teamShare = try await lara.glossaries.addAccountShare(id: glossaryId, name: "Shared with the team")
            print("🤝 Shared with the account as: '\(teamShare.name)' (shared at \(teamShare.sharedAt))")

            // Rename the account/team share
            let renamedTeamShare = try await lara.glossaries.renameAccountShare(id: glossaryId, name: "Team glossary")
            print("📝 Renamed account share to: '\(renamedTeamShare.name)'")

            // List every share visible to the caller: the account share, group shares and user shares
            let shares = try await lara.glossaries.getShares(id: glossaryId)
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
            _ = try await lara.glossaries.revokeAccountShare(id: glossaryId)
            print("🚫 Revoked the account share")

            // Group shares work the same way, addressed by a group ID (grp_...)
            if let groupId = ProcessInfo.processInfo.environment["LARA_GROUP_ID"] {
                let groupShare = try await lara.glossaries.addGroupShare(id: glossaryId, groupId: groupId, name: "Shared with the group")
                print("🤝 Shared with group \(groupId) as: '\(groupShare.name)'")

                _ = try await lara.glossaries.renameGroupShare(id: glossaryId, groupId: groupId, name: "Marketing group")
                print("📝 Renamed the group share")

                _ = try await lara.glossaries.revokeGroupShare(id: glossaryId, groupId: groupId)
                print("🚫 Revoked the group share")
            } else {
                print("Set LARA_GROUP_ID to try the group sharing methods.")
            }
            print()
        } catch {
            print("Error sharing glossary: \(error)")
        }

        // Cleanup
        print("=== Cleanup ===")
        let deletedGlossary = try await lara.glossaries.delete(id: glossaryId)
        print("🗑️  Deleted glossary: \(deletedGlossary.name)")

        // Clean up export files - replace with actual cleanup if needed
        if FileManager.default.fileExists(atPath: exportFilePath) {
            try FileManager.default.removeItem(atPath: exportFilePath)
            print("🗑️  Cleaned up export file")
        }

        print("\n🎉 Glossary management examples completed!")

    } catch {
        print("❌ Error: \(error.localizedDescription)")
    }
}

Task {
    await main()
}
