import Lara
import Foundation

// Complete document translation examples for the Lara Swift SDK
//
// This example demonstrates:
// - Basic document translation
// - Advanced options with memories and glossaries
// - Step-by-step translation with status monitoring

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"

    // Set your credentials here
    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    // Replace with your actual document file path
    let sampleFilePath = "sample_document.docx"  // Create this file with your content

    if !FileManager.default.fileExists(atPath: sampleFilePath) {
        print("Please create a sample document file at: \(sampleFilePath)")
        print("Add some sample text content to translate.\n")
        return
    }

    do {
        // Example 1: Basic document translation
        print("=== Basic Document Translation ===")
        let sourceLang = "en-US"
        let targetLang = "de-DE"

        print("Translating document: \(FileManager.default.displayName(atPath: sampleFilePath)) from \(sourceLang) to \(targetLang)")

        let documentData = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))
        let translatedData = try await lara.documents.translate(
            data: documentData,
            filename: FileManager.default.displayName(atPath: sampleFilePath),
            source: sourceLang,
            target: targetLang
        )

        // Save translated document - replace with your desired output path
        let outputPath = "sample_document_translated.docx"
        try translatedData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Document translation completed")
        print("📄 Translated file saved to: \(FileManager.default.displayName(atPath: outputPath))\n")

        // Example 2: Document translation with advanced options
        print("=== Document Translation with Advanced Options ===")

        let documentData2 = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))

        // Replace with actual memory/glossary IDs
        let translatedData2 = try await lara.documents.translate(
            data: documentData2,
            filename: FileManager.default.displayName(atPath: sampleFilePath),
            source: sourceLang,
            target: targetLang,
            options: DocumentTranslateOptions(
                adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],
                glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"]
            )
        )

        // Save translated document - replace with your desired output path
        let outputPath2 = "advanced_document_translated.docx"
        try translatedData2.write(to: URL(fileURLWithPath: outputPath2))
        print("✅ Advanced document translation completed")
        print("📄 Translated file saved to: \(FileManager.default.displayName(atPath: outputPath2))\n")

        // Example 3: Step-by-step document translation
        print("=== Step-by-Step Document Translation ===")

        let documentData3 = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))

        // Upload document
        print("Step 1: Uploading document...")

        let uploadOptions = DocumentUploadOptions(
            adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],
            glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"]
        )

        let document = try await lara.documents.upload(
            data: documentData3,
            filename: FileManager.default.displayName(atPath: sampleFilePath),
            source: sourceLang,
            target: targetLang,
            options: uploadOptions
        )

        print("Document uploaded with ID: \(document.id)")
        print("Initial status: \(document.status)")
        print()

        // Check status
        print("Step 2: Checking status...")
        let currentStatus = try await lara.documents.status(id: document.id)
        print("Current status: \(currentStatus.status)")

        // Download translated document
        print("\nStep 3: Downloading translated document...")
        let downloadedContent = try await lara.documents.download(id: document.id)

        let stepByStepOutputPath = "step_by_step_translated.docx"
        try downloadedContent.write(to: URL(fileURLWithPath: stepByStepOutputPath))
        print("✅ Step-by-step translation completed")
        print("📄 Downloaded file saved to: \(stepByStepOutputPath)")

    } catch {
        print("❌ Error: \(error.localizedDescription)")
    }
}

Task {
    await main()
}
