import Lara
import Foundation

// Complete memory management examples for the Lara Swift SDK
//
// This example demonstrates:
// - Create, list, update, delete memories
// - Add individual translations
// - Multiple memory operations
// - TMX file import with progress monitoring
// - Translation deletion
// - Translation with TUID and context

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"

    // Set your credentials here
    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    do {
        // Example 1: Basic memory management
        print("=== Basic Memory Management ===")
        let memory = try await lara.memories.create(name: "MyDemoMemory")
        print("✅ Created memory: \(memory.name) (ID: \(memory.id))")

        let memoryId = memory.id

        // Get memory details
        let retrievedMemory = try await lara.memories.get(id: memoryId)
        print("📖 Memory: \(retrievedMemory.name) (Owner: \(retrievedMemory.ownerId ?? "Unknown"))")

        // Update memory
        let updatedMemory = try await lara.memories.update(id: memoryId, name: "UpdatedDemoMemory")
        print("📝 Updated name: '\(memoryId)' -> '\(updatedMemory.name)'")

        // List all memories
        let memories = try await lara.memories.list()
        print("📝 Total memories: \(memories.count)")

        // Example 2: Adding translations
        // Important: To update/overwrite a translation unit you must provide a tuid. Calls without a tuid always create a new unit and will not update existing entries.
        print("=== Adding Translations ===")

        // Basic translation addition (with TUID)
        let memoryImport1 = try await lara.memories.addTranslation(
            id: memoryId,
            source: "en-US",
            target: "fr-FR",
            sentence: "Hello",
            translation: "Bonjour",
            tuid: "greeting_001"
        )
        print("✅ Added: 'Hello' -> 'Bonjour' with TUID 'greeting_001' (Import ID: \(memoryImport1.id))")

        // Translation with context
        let memoryImport2 = try await lara.memories.addTranslation(
            id: memoryId,
            source: "en-US",
            target: "fr-FR",
            sentence: "How are you?",
            translation: "Comment allez-vous?",
            tuid: "greeting_002",
            sentenceBefore: "Good morning",
            sentenceAfter: "Have a nice day"
        )
        print("✅ Added with context (Import ID: \(memoryImport2.id))")

        // Example 3: Multiple memory operations
        print("=== Multiple Memory Operations ===")

        // Create second memory for multi-memory operations
        let secondMemory = try await lara.memories.create(name: "SecondDemoMemory")
        print("✅ Created second memory: \(secondMemory.name)")

        // Add translation to multiple memories (with TUID)
        let memoryIds = [memoryId, secondMemory.id]
        let memoryImport3 = try await lara.memories.addTranslation(
            ids: memoryIds,
            source: "en-US",
            target: "it-IT",
            sentence: "Hello World!",
            translation: "Ciao Mondo!",
            tuid: "greeting_003"
        )
        print("✅ Added translation to multiple memories (Import ID: \(memoryImport3.id))")
        print()

        // Example 4: TMX import functionality
        print("=== TMX Import Functionality ===")

        // Replace with your actual TMX file path
        let tmxFilePath = "sample_memory.tmx"  // Create this file with your TMX content

        if FileManager.default.fileExists(atPath: tmxFilePath) {
            print("Importing TMX file: \(FileManager.default.displayName(atPath: tmxFilePath))")

            let tmxData = try Data(contentsOf: URL(fileURLWithPath: tmxFilePath))
            let memoryImport4 = try await lara.memories.importTmx(id: memoryId, tmx: tmxData, gzip: false)
            print("Import started with ID: \(memoryImport4.id)")
            print("Initial progress: \(Int(memoryImport4.progress * 100))%")

            // Wait for import to complete
            let completedImport = try await lara.memories.waitForImport(memoryImport4, maxWaitTime: 300)  // 5 minutes timeout
            print("✅ Import completed!")
            print("Final progress: \(Int(completedImport.progress * 100))%")
        } else {
            print("TMX file not found: \(tmxFilePath)")
        }

        print()

        // Example 5: Translation deletion
        print("=== Translation Deletion ===")

        // Delete a specific translation unit (with TUID)
        // Important: if you omit tuid, all entries that match the provided fields will be removed
        let memoryImportDeletion = try await lara.memories.deleteTranslation(
            id: memoryId,
            source: "en-US",
            target: "fr-FR",
            sentence: "Hello",
            translation: "Bonjour",
            tuid: "greeting_001"  // Specify the TUID to delete a specific translation unit
        )
        print("🗑️  Deleted translation unit (Job ID: \(memoryImportDeletion.id))")
        print()

        // Cleanup
        print("=== Cleanup ===")
        let deletedMemory = try await lara.memories.delete(id: memoryId)
        print("🗑️  Deleted memory: \(deletedMemory.name)")

        let deletedSecondMemory = try await lara.memories.delete(id: secondMemory.id)
        print("🗑️  Deleted second memory: \(deletedSecondMemory.name)")

        print("\n🎉 Memory management examples completed!")

    } catch {
        print("❌ Error: \(error.localizedDescription)")
    }
}

Task {
    await main()
}
