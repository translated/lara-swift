import Lara
import Foundation

/**
 * Complete image translation examples for the Lara Swift SDK
 *
 * This example demonstrates:
 * - Basic image translation (image output)
 * - Advanced options with memories and glossaries
 * - Extracting and translating text from an image
 * - Creating MultipartFile objects from image data
 */

func main() async {
    // All examples can use environment variables for credentials:
    // export LARA_ACCESS_KEY_ID="your-access-key-id"
    // export LARA_ACCESS_KEY_SECRET="your-access-key-secret"

    // Set your credentials here
    let accessKeyId = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"] ?? "your-access-key-id"
    let accessKeySecret = ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"] ?? "your-access-key-secret"

    let credentials = Credentials(accessKeyId: accessKeyId, accessKeySecret: accessKeySecret)
    let lara = Translator(credentials: credentials)

    // Replace with your actual image file path
    let sampleFilePath = "./sample_image.png"

    let sampleFileURL = URL(fileURLWithPath: sampleFilePath)

    guard FileManager.default.fileExists(atPath: sampleFilePath) else {
        print("Please create a sample image file at: \(sampleFilePath)")
        return
    }

    do {
        // Load the image data
        let imageData = try Data(contentsOf: sampleFileURL)
        let sourceLang = "en"
        let targetLang = "de"

        // Example 1: Basic image translation (image output)
        print("=== Basic Image Translation ===")
        print("Translating image: \(sampleFilePath) from \(sourceLang) to \(targetLang)")

        // Create a MultipartFile from the image data
        let file = MultipartFile(filename: "sample_image.png", data: imageData)

        let translatedImageData = try await lara.images.translate(
            file: file,
            source: sourceLang,
            target: targetLang,
            options: ImageTranslationOptions(textRemoval: .overlay)
        )

        // Save the translated image
        let outputPath = "./sample_image_translated.png"
        try translatedImageData.write(to: URL(fileURLWithPath: outputPath))

        print("✅ Image translation completed")
        print("📄 Translated image saved to: \(outputPath)\n")

        // Example 2: Image translation with advanced options
        print("=== Image Translation with Advanced Options ===")

        // Create another MultipartFile for the advanced example
        let file2 = MultipartFile(filename: "sample_image.png", data: imageData)

        let advancedOptions = ImageTranslationOptions(
            adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"], // Replace with actual memory IDs
            glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"], // Replace with actual glossary IDs
            style: .faithful,
            textRemoval: .inpainting
        )

        let translatedImageData2 = try await lara.images.translate(
            file: file2,
            source: sourceLang,
            target: targetLang,
            options: advancedOptions
        )

        // Save the advanced translated image
        let outputPath2 = "./advanced_image_translated.png"
        try translatedImageData2.write(to: URL(fileURLWithPath: outputPath2))

        print("✅ Advanced image translation completed")
        print("📄 Translated image saved to: \(outputPath2)\n")

        // Example 3: Extract and translate text from an image
        print("=== Extract and Translate Text ===")

        // Create another MultipartFile for text extraction
        let file3 = MultipartFile(filename: "sample_image.png", data: imageData)

        let textOptions = ImageTextTranslationOptions(
            adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"], // Replace with actual memory IDs
            glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"], // Replace with actual glossary IDs
            style: .faithful
        )

        let results = try await lara.images.translateText(
            file: file3,
            source: sourceLang,
            target: targetLang,
            options: textOptions
        )

        print("✅ Extract and translate completed")
        print("Found \(results.paragraphs.count) text blocks")

        // Display each text block and its translation
        for (index, paragraph) in results.paragraphs.enumerated() {
            print("\nText Block \(index + 1):")
            print("Original: \(paragraph.text)")
            print("Translated: \(paragraph.translation)")

        }

        print("\n🎉 All image translation examples completed successfully!")

    } catch {
        print("❌ Error: \(error.localizedDescription)")
    }
}

Task {
    await main()
}