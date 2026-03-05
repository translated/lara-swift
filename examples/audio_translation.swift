import Lara
import Foundation

// Complete audio translation examples for the Lara Swift SDK
//
// This example demonstrates:
// - Basic audio translation
// - Advanced options with memories and glossaries
// - Step-by-step audio translation with status monitoring

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"

    // Set your credentials here
    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    // Replace with your actual audio file path
    let sampleFilePath = "sample_audio.mp3"  // Create this file with your content

    if !FileManager.default.fileExists(atPath: sampleFilePath) {
        print("Please create a sample audio file at: \(sampleFilePath)")
        print("Add some sample audio content to translate.\n")
        return
    }

    do {
        // Example 1: Basic audio translation
        print("=== Basic Audio Translation ===")
        let sourceLang = "en-US"
        let targetLang = "de-DE"

        print("Translating audio: \(FileManager.default.displayName(atPath: sampleFilePath)) from \(sourceLang) to \(targetLang)")

        let audioData = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))
        let translatedData = try await lara.audio.translate(
            data: audioData,
            filename: FileManager.default.displayName(atPath: sampleFilePath),
            source: sourceLang,
            target: targetLang
        )

        // Save translated audio - replace with your desired output path
        let outputPath = "sample_audio_translated.mp3"
        try translatedData.write(to: URL(fileURLWithPath: outputPath))

        print("✅ Audio translation completed")
        print("📄 Translated file saved to: \(FileManager.default.displayName(atPath: outputPath))\n")
    } catch {
        print("Error translating audio: \(error.localizedDescription)\n")
        return
    }

    // Example 2: Audio translation with advanced options
    print("=== Audio Translation with Advanced Options ===")
    do {
        let audioData = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))
        let translatedData = try await lara.audio.translate(
            data: audioData,
            filename: FileManager.default.displayName(atPath: sampleFilePath),
            source: sourceLang,
            target: targetLang,
            options: AudioUploadOptions(
                adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
                glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"]  // Replace with actual glossary IDs
            )
        )

        // Save translated audio - replace with your desired output path
        let outputPath = "advanced_audio_translated.mp3"
        try translatedData.write(to: URL(fileURLWithPath: outputPath))

        print("✅ Advanced Audio translation completed")
        print("📄 Translated file saved to: \(FileManager.default.displayName(atPath: outputPath))\n")
    } catch {
        print("Error in advanced translation: \(error.localizedDescription)")
    }

    // Example 3: Step-by-step audio translation
    print("=== Step-by-Step Audio Translation ===")

    do {
        // Upload audio
        print("Step 1: Uploading audio...")
        let audioData = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))
        let audio = try await lara.audio.upload(
            data: audioData,
            filename: FileManager.default.displayName(atPath: sampleFilePath),
            source: sourceLang,
            target: targetLang,
            options: AudioUploadOptions(
                adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
                glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"]  // Replace with actual glossary IDs
            )
        )
        print("Audio uploaded with ID: \(audio.id)")
        print("Initial status: \(audio.status)")

        // Check status with polling
        print("\nStep 2: Checking status...")
        var updatedAudio = try await lara.audio.status(id: audio.id)
        print("Current status: \(updatedAudio.status)")

        // Poll until translation is complete
        while updatedAudio.status != .translated {
            updatedAudio = try await lara.audio.status(id: audio.id)
            print("Current status: \(updatedAudio.status)")

            if updatedAudio.status == .error {
                throw NSError(domain: "AudioTranslationError",
                            code: 500,
                            userInfo: [NSLocalizedDescriptionKey: updatedAudio.errorReason ?? "Translation failed"])
            }

            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }

        // Download translated audio
        print("\nStep 3: Downloading translated audio...")
        let translatedData = try await lara.audio.download(id: audio.id)

        // Save translated audio - replace with your desired output path
        let outputPath = "step_audio_translated.mp3"
        try translatedData.write(to: URL(fileURLWithPath: outputPath))

        print("✅ Step-by-step translation completed")
        print("📄 Translated file saved to: \(FileManager.default.displayName(atPath: outputPath))")
    } catch {
        print("Error in step-by-step process: \(error.localizedDescription)")
    }
}

await main()