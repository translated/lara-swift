import Lara
import Foundation

// Complete styleguide management examples for the Lara Swift SDK
//
// This example demonstrates:
// - Create, list, get, update, delete styleguides

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
            print("   Personal: \(retrieved.isPersonal ?? false)")
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
