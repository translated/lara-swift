import Lara
import Foundation

// Complete text translation examples for the Lara Swift SDK
//
// This example demonstrates:
// - Single string translation
// - Multiple strings translation
// - Translation with instructions
// - TextBlocks translation (mixed translatable/non-translatable content)
// - Auto-detect source language
// - Advanced translation options
// - Get available languages
// - Language Detection

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"
    // Falls back to placeholders if not set
    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    do {
        // Example 1: Basic single string translation
        print("=== Basic Single String Translation ===")
        let translation = try await lara.translate(text: "Hello, world!", source: "en-US", target: "fr-FR")
        if let translations = try? translation.translation.getTranslations() {
            print("Original: Hello, world!")
            print("French: \(translations.first ?? "No translation")\n")
        }

        // Example 2: Multiple strings translation
        print("=== Multiple Strings Translation ===")
        let texts = ["Hello", "How are you?", "Goodbye"]
        let translation2 = try await lara.translate(text: texts, source: "en-US", target: "es-ES")
        if let translations = try? translation2.translation.getTranslations() {
            print("Original: \(texts)")
            print("Spanish: \(translations)\n")
        }

        // Example 3: TextBlocks translation (mixed translatable/non-translatable content)
        print("=== TextBlocks Translation ===")
        let textBlocks = [
            TextBlock(text: "Adventure novels, mysteries, cookbooks—wait, who packed those?", translatable: true),
            TextBlock(text: "<br>", translatable: false),  // Non-translatable HTML
            TextBlock(text: "Suddenly, it doesn't feel so deserted after all.", translatable: true),
            TextBlock(text: "<div class=\"separator\"></div>", translatable: false),
            TextBlock(text: "Every page you turn is a new journey, and the best part?", translatable: true)
        ]

        let translation3 = try await lara.translate(text: textBlocks, source: "en-US", target: "it-IT")
        if let translations = try? translation3.translation.getTranslations() {
            print("Original TextBlocks: \(textBlocks.count) blocks")
            print("Translated blocks: \(translations.count)")
            for (i, translation) in translations.enumerated() {
                print("Block \(i + 1): \(translation)")
            }
            print()
        }

        // Example 4: Translation with instructions
        print("=== Translation with Instructions ===")
        let options1 = TranslateOptions(
            instructions: ["Be formal", "Use technical terminology"]
        )

        let translation4 = try await lara.translate(text: "Could you send me the report by tomorrow morning?", source: "en-US", target: "de-DE", options: options1)
        if let translations = try? translation4.translation.getTranslations() {
            print("Original: Could you send me the report by tomorrow morning?")
            print("German (formal): \(translations.first ?? "No translation")\n")
        }

        // Example 5: Auto-detecting source language
        print("=== Auto-detect Source Language ===")
        let translation5 = try await lara.translate(text: "Bonjour le monde!", target: "en-US")
        if let translations = try? translation5.translation.getTranslations() {
            print("Original: Bonjour le monde!")
            print("Detected source: \(translation5.sourceLanguage ?? "Unknown")")
            print("English: \(translations.first ?? "No translation")\n")
        }

        // Example 6: Advanced options with comprehensive settings
        print("=== Translation with Advanced Options ===")

        let options2 = TranslateOptions(
            adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl", "mem_2XyZ9AbC8dEf7GhI6jKlMn"], // Replace with actual memory IDs
            glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl", "gls_2XyZ9AbC8dEf7GhI6jKlMn"], // Replace with actual glossary IDs
            instructions: ["Be professional"],
            style: .fluid,
            contentType: "text/plain",
            timeoutMs: 10000
        )

        let translation6 = try await lara.translate(text: "This is a comprehensive translation example", source: "en-US", target: "it-IT", options: options2)
        if let translations = try? translation6.translation.getTranslations() {
            print("Original: This is a comprehensive translation example")
            print("Italian (with all options): \(translations.first ?? "No translation")\n")
        }

        // Example 7: Get available languages
        print("=== Available Languages ===")
        let languages = try await lara.getLanguages()
        print("Supported languages: \(languages)")

        // Example 8: Detect language of a given text
        print("=== Language Detection ===")
        let detectResult = try await lara.detect(text: "Hola, ¿cómo estás?")
        print("Text: Hola, ¿cómo estás?")
        print("Detected Language: \(detectResult.language)")

        // Example 9: Detect languages with hint and passlist
        print("=== Language Detection with Hint and Passlist ===")
        let detectResult2 = try await lara.detect(text: "Hola, ¿cómo estás?", hint: "es", passlist: ["es", "pt", "it"])
        print("Text: Hola, ¿cómo estás?")
        print("Detected Language: \(detectResult2.language)")

    } catch {
        print("❌ General error: \(error.localizedDescription)")
    }
}

Task {
    await main()
}
