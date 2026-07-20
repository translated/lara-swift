import Lara
import Foundation

// Complete audio transcript translation examples for the Lara Swift SDK
//
// This example demonstrates the async Audio2Text flow, which returns only the
// translated transcript (JSON) instead of a dubbed audio file:
// - Basic transcript translation
// - Advanced options with memories and glossaries
// - Step-by-step transcript translation with status monitoring

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"

    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    // Replace with your actual audio file path
    let sampleFilePath = "sample_audio.mp3" // Create this file with your content

    if !FileManager.default.fileExists(atPath: sampleFilePath) {
        print("Please create a sample audio file at: \(sampleFilePath)")
        print("Add some sample audio content to translate.\n")
        return
    }

    let sourceLang = "en-US"
    let targetLang = "de-DE"
    let filename = FileManager.default.displayName(atPath: sampleFilePath)

    // Example 1: Basic transcript translation
    print("=== Basic Transcript Translation ===")
    print("Translating transcript: \(filename) from \(sourceLang) to \(targetLang)")

    do {
        let audioData = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))
        let result = try await lara.audio.translateTranscript(
            data: audioData,
            filename: filename,
            source: sourceLang,
            target: targetLang
        )

        print("✅ Transcript translation completed")
        print("📝 Translation: \(result.translation)")
        print("🔎 Segments: \(result.segments.count)\n")
    } catch {
        print("Error translating transcript: \(error.localizedDescription)\n")
        return
    }

    // Example 2: Transcript translation with advanced options
    print("=== Transcript Translation with Advanced Options ===")
    do {
        let audioData = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))
        let result2 = try await lara.audio.translateTranscript(
            data: audioData,
            filename: filename,
            source: sourceLang,
            target: targetLang,
            options: AudioTranscriptUploadOptions(
                adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
                glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"]  // Replace with actual glossary IDs
            )
        )

        print("✅ Advanced transcript translation completed")
        print("📝 Translation: \(result2.translation)\n")
    } catch {
        print("Error in advanced translation: \(error.localizedDescription)")
    }

    // Example 3: Step-by-step transcript translation
    print("=== Step-by-Step Transcript Translation ===")

    do {
        print("Step 1: Uploading audio...")
        let audioData = try Data(contentsOf: URL(fileURLWithPath: sampleFilePath))
        let audio = try await lara.audio.uploadForTranscription(
            data: audioData,
            filename: filename,
            source: sourceLang,
            target: targetLang,
            options: AudioTranscriptUploadOptions(
                adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
                glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"]  // Replace with actual glossary IDs
            )
        )
        print("Audio uploaded with ID: \(audio.id)")
        print("Initial status: \(audio.status)")

        print("\nStep 2: Checking status...")
        var updatedAudio = try await lara.audio.status(id: audio.id)
        print("Current status: \(updatedAudio.status)")

        while updatedAudio.status != AudioStatus.translated {
            updatedAudio = try await lara.audio.status(id: audio.id)
            print("Current status: \(updatedAudio.status)")

            if updatedAudio.status == AudioStatus.error {
                throw NSError(
                    domain: "AudioTranslationError",
                    code: 500,
                    userInfo: [NSLocalizedDescriptionKey: updatedAudio.errorReason ?? "Translation failed"]
                )
            }

            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }

        print("\nStep 3: Retrieving translated transcript...")
        let result3 = try await lara.audio.getTranslatedTranscript(id: audio.id)

        print("✅ Step-by-step transcript translation completed")
        print("📝 Translation: \(result3.translation)")
        print("🔎 Segments: \(result3.segments.count)")
    } catch {
        print("Error in step-by-step process: \(error.localizedDescription)")
    }
}

await main()
