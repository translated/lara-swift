# Lara Swift SDK

[![Swift Version](https://img.shields.io/badge/swift-5.5+-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

This SDK empowers you to build your own branded translation AI leveraging our translation fine-tuned language model.

All major translation features are accessible, making it easy to integrate and customize for your needs.

## 🌍 **Features:**
- **Text Translation**: Single strings, multiple strings, and complex text blocks
- **Document Translation**: Word, PDF, and other document formats with status monitoring
- **Image Translation**: Translate images or text within images
- **Audio Translation**: MP3, WAV, and other audio formats with status monitoring
- **Translation Memory**: Store and reuse translations for consistency
- **Glossaries**: Enforce terminology standards across translations
- **Language Detection**: Automatic source language identification
- **Advanced Options**: Translation instructions and more

## 📚 Documentation

Lara's SDK full documentation is available at [https://developers.laratranslate.com/](https://developers.laratranslate.com/)

## 🚀 Quick Start

### Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/translated/lara-swift.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import Lara

// Set your credentials using environment variables (recommended)
let credentials = Credentials(
    accessKeyId: ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"]!,
    accessKeySecret: ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"]!
)

// Create translator instance
let lara = Translator(credentials: credentials)

// Simple text translation
let translation = try await lara.translate(text: "Hello, world!", source: "en", target: "fr")
if let translations = try? translation.translation.getTranslations() {
    print("Translation: \(translations.first ?? "No translation")")
    // Output: Translation: Bonjour, le monde !
}
```

## 📖 Examples

The `examples/` directory contains comprehensive examples for all SDK features.

**All examples use environment variables for credentials, so set them first:**
```bash
export LARA_ACCESS_KEY_ID="your-access-key-id"
export LARA_ACCESS_KEY_SECRET="your-access-key-secret"
```

### Text Translation
- **[text_translation.swift](examples/text_translation.swift)** - Complete text translation examples
  - Single string translation
  - Multiple strings translation
  - Translation with instructions
  - TextBlocks translation (mixed translatable/non-translatable content)
  - Auto-detect source language
  - Advanced translation options
  - Get available languages
  - Language Detection

```bash
cd examples
swift run text_translation.swift
```

### Document Translation
- **[document_translation.swift](examples/document_translation.swift)** - Document translation examples
  - Basic document translation
  - Advanced options with memories and glossaries
  - Step-by-step translation with status monitoring

```bash
cd examples
swift run document_translation.swift
```

### Image Translation
- **[image_translation.swift](examples/image_translation.swift)** - Complete image translation examples
  - Basic image translation with text overlay
  - Advanced options with memories, glossaries, and inpainting
  - Extract and translate text from images

```bash
cd examples
swift run image_translation.swift
```

### Audio Translation
- **[audio_translation.swift](examples/audio_translation.swift)** - Audio translation examples
  - Basic audio translation
  - Advanced options with memories and glossaries
  - Step-by-step translation with status monitoring

```bash
cd examples
swift run audio_translation.swift
```

### Translation Memory Management
- **[memories_management.swift](examples/memories_management.swift)** - Memory management examples
  - Create, list, update, delete memories
  - Add individual translations
  - Multiple memory operations
  - TMX file import with progress monitoring
  - Translation deletion
  - Translation with TUID and context

```bash
cd examples
swift run memories_management.swift
```

### Glossary Management
- **[glossaries_management.swift](examples/glossaries_management.swift)** - Glossary management examples
  - Create, list, update, delete glossaries
  - Individual term management (add/remove terms)
  - CSV import with status monitoring
  - Glossary export
  - Glossary terms count
  - Import status checking

```bash
cd examples
swift run glossaries_management.swift
```

## 🔧 API Reference

### Core Components

### 🔐 Authentication

The SDK supports authentication via access key and secret:

```swift
import Lara

let credentials = Credentials(accessKeyId: "your-access-key-id", accessKeySecret: "your-access-key-secret")
let lara = Translator(credentials: credentials)
```

**Environment Variables (Recommended):**
```bash
export LARA_ACCESS_KEY_ID="your-access-key-id"
export LARA_ACCESS_KEY_SECRET="your-access-key-secret"
```

```swift
import Lara

let credentials = Credentials(
    accessKeyId: ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_ID"]!,
    accessKeySecret: ProcessInfo.processInfo.environment["LARA_ACCESS_KEY_SECRET"]!
)
```

### 🌍 Translator

```swift
// Create translator with credentials
let lara = Translator(credentials: credentials)
```

#### Text Translation

```swift
// Basic translation
let translation = try await lara.translate(text: "Hello", source: "en", target: "fr")

// Multiple strings
let texts = ["Hello", "World"]
let translations = try await lara.translate(text: texts, source: "en", target: "fr")

// TextBlocks (mixed translatable/non-translatable content)
let textBlocks = [
    TextBlock(text: "Translatable text", translatable: true),
    TextBlock(text: "<br>", translatable: false),  // Non-translatable HTML
    TextBlock(text: "More translatable text", translatable: true)
]
let textBlockTranslations = try await lara.translate(text: textBlocks, source: "en", target: "fr")

// With advanced options
let options = TranslateOptions(
    instructions: ["Formal tone"],
    adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
    glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual glossary IDs
    style: .fluid,
    timeoutMs: 10000
)

let advancedTranslation = try await lara.translate(text: "Hello", source: "en", target: "fr", options: options)
```

### 📖 Document Translation
#### Simple document translation
```swift
import Foundation

// Replace with your actual file path
let fileURL = URL(fileURLWithPath: "/path/to/your/document.txt")
let fileData = try Data(contentsOf: fileURL)

let translatedData = try await lara.documents.translate(
    data: fileData,
    filename: "document.txt",
    source: "en",
    target: "fr"
)

// With options
let options = DocumentTranslateOptions(
    adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
    glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual glossary IDs
    style: .fluid
)

let translatedDataWithOptions = try await lara.documents.translate(
    data: fileData,
    filename: "document.txt",
    source: "en",
    target: "fr",
    options: options
)
```

### Document translation with status monitoring
#### Document upload
```swift
//Optional: upload options
let uploadOptions = DocumentUploadOptions(
    adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
    glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual glossary IDs
    noTrace: true,
    style: .fluid
)

let document = try await lara.documents.upload(
    data: fileData,
    filename: "document.txt",
    source: "en",
    target: "fr",
    options: uploadOptions
)
```
#### Document translation status monitoring
```swift
let status = try await lara.documents.status(id: documentId)
```
#### Download translated document
```swift
let downloadedData = try await lara.documents.download(id: documentId)
```

### 🖼️ Image Translation
```swift
import Foundation

// Load image data
let imageURL = URL(fileURLWithPath: "/path/to/your/image.jpg")
let imageData = try Data(contentsOf: imageURL)

// Create MultipartFile
let file = MultipartFile(filename: "image.jpg", data: imageData)

// Basic image translation
let translatedImageData = try await lara.images.translate(
    file: file,
    source: "en",
    target: "fr",
    options: ImageTranslationOptions(textRemoval: .overlay)
)

// Extract and translate text from image
let textResults = try await lara.images.translateText(
    file: file,
    source: "en",
    target: "fr",
    options: ImageTextTranslationOptions(
        adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"], // Memory IDs
        glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"] // Glossary IDs
    )
)
```

### 🔊 Audio Translation
#### Simple audio translation
```swift
import Foundation

// Replace with your actual file path
let fileURL = URL(fileURLWithPath: "/path/to/your/audio.mp3")
let fileData = try Data(contentsOf: fileURL)

let translatedData = try await lara.audio.translate(
    data: fileData,
    filename: "audio.mp3",
    source: "en",
    target: "fr"
)

// With options
let options = AudioUploadOptions(
    adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
    glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual glossary IDs
    style: .fluid
)

let translatedDataWithOptions = try await lara.audio.translate(
    data: fileData,
    filename: "audio.mp3",
    source: "en",
    target: "fr",
    options: options
)
```

### 🔊 Audio Translation with Status Monitoring
#### Audio upload
```swift
//Optional: upload options
let uploadOptions = AudioUploadOptions(
    adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual memory IDs
    glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"],  // Replace with actual glossary IDs
    noTrace: true,
    style: .fluid
)

let audio = try await lara.audio.upload(
    data: fileData,
    filename: "audio.mp3",
    source: "en",
    target: "fr",
    options: uploadOptions
)
```
#### Audio translation status monitoring
```swift
let status = try await lara.audio.status(id: audioId)
```
#### Download translated audio
```swift
let downloadedData = try await lara.audio.download(id: audioId)
```

### 🧠 Memory Management

```swift
// Create memory
let memory = try await lara.memories.create(name: "MyMemory")

// Create memory with external ID (MyMemory integration)
let memoryWithExternalId = try await lara.memories.create(name: "Memory from MyMemory", externalId: "aabb1122")

// Important: To update/overwrite a translation unit you must provide a tuid. Calls without a tuid always create a new unit and will not update existing entries.
// Add translation to single memory
let memoryImport = try await lara.memories.addTranslation(
    id: "mem_1A2b3C4d5E6f7G8h9I0jKl",
    source: "en",
    target: "fr",
    sentence: "Hello",
    translation: "Bonjour",
    tuid: "greeting_001"
)

// Add translation to multiple memories
let memoryIds = ["mem_1A2b3C4d5E6f7G8h9I0jKl", "mem_2XyZ9AbC8dEf7GhI6jKlMn"]
let bulkMemoryImport = try await lara.memories.addTranslation(
    ids: memoryIds,
    source: "en",
    target: "fr",
    sentence: "Hello",
    translation: "Bonjour",
    tuid: "greeting_002"
)

// Add with context
let memoryImportWithContext = try await lara.memories.addTranslation(
    id: "mem_1A2b3C4d5E6f7G8h9I0jKl",
    source: "en",
    target: "fr",
    sentence: "Hello",
    translation: "Bonjour",
    tuid: "tuid",
    sentenceBefore: "sentenceBefore",
    sentenceAfter: "sentenceAfter"
)

// TMX import from file URL
let tmxFileURL = URL(fileURLWithPath: "/path/to/your/memory.tmx")
let tmxData = try Data(contentsOf: tmxFileURL)
let tmxImport = try await lara.memories.importTmx(id: "mem_1A2b3C4d5E6f7G8h9I0jKl", tmx: tmxData)

// Wait for import completion (timeout in SECONDS)
let completedImport = try await lara.memories.waitForImport(tmxImport, maxWaitTime: 300)  // 5 minutes

// Delete translation
// Important: if you omit tuid, all entries that match the provided fields will be removed
let deleteResult = try await lara.memories.deleteTranslation(
    id: "mem_1A2b3C4d5E6f7G8h9I0jKl",
    source: "en",
    target: "fr",
    sentence: "Hello",
    translation: "Bonjour",
    tuid: "greeting_001"
)
```

### 📚 Glossary Management

```swift
// Create glossary
let glossary = try await lara.glossaries.create(name: "MyGlossary")

// Import CSV from file URL
let csvFileURL = URL(fileURLWithPath: "/path/to/your/glossary.csv")
let csvData = try Data(contentsOf: csvFileURL)
let glossaryImport = try await lara.glossaries.importCsv(id: "gls_1A2b3C4d5E6f7G8h9I0jKl", csv: csvData)

// Add (or replace) individual terms to glossary
let terms = [
    ["language": "fr-FR", "value": "Bonjour"],
    ["language": "es-ES", "value": "Hola"]
]
_ = try await lara.glossaries.addOrReplaceEntry(glossaryId: "gls_1A2b3C4d5E6f7G8h9I0jKl", terms: terms, guid: nil)

// Remove a specific term from glossary
let termToRemove = ["language": "fr-FR", "value": "Bonjour"]
_ = try await lara.glossaries.deleteEntry(glossaryId: "gls_1A2b3C4d5E6f7G8h9I0jKl", term: termToRemove, guid: nil)

// Check import status
let importStatus = try await lara.glossaries.getImportStatus(id: "gls_1A2b3C4d5E6f7G8h9I0jKl")

// Wait for import completion
let completedGlossaryImport = try await lara.glossaries.waitForImport(glossaryImport, maxWaitTime: 300)  // 5 minutes

// Export glossary
let csvExport = try await lara.glossaries.export(id: "gls_1A2b3C4d5E6f7G8h9I0jKl", source: "en")

// Get glossary terms count
let termCounts = try await lara.glossaries.counts(id: "gls_1A2b3C4d5E6f7G8h9I0jKl")
```

### Translation Options

```swift
let options = TranslateOptions(
    adaptTo: ["mem_1A2b3C4d5E6f7G8h9I0jKl"],              // Memory IDs to adapt to
    glossaries: ["gls_1A2b3C4d5E6f7G8h9I0jKl"],           // Glossary IDs to use
    instructions: ["instruction"],                        // Translation instructions
    style: .fluid,                                        // Translation style (.fluid, .faithful, .creative)
    contentType: "text/plain",                            // Content type (text/plain, text/html, etc.)
    multiline: true,                                      // Enable multiline translation
    timeoutMs: 10000,                                     // Request timeout in milliseconds
    noTrace: false,                                       // Disable request tracing
    verbose: false                                        // Enable verbose response
)
```

### Language Codes

The SDK supports full language codes (e.g., `en-US`, `fr-FR`, `es-ES`) as well as simple codes (e.g., `en`, `fr`, `es`):

```swift
// Full language codes (recommended)
let translation = try await lara.translate(text: "Hello", source: "en-US", target: "fr-FR")

// Simple language codes
let translation2 = try await lara.translate(text: "Hello", source: "en", target: "fr")
```

### 🌐 Supported Languages

The SDK supports all languages available in the Lara API. Use the `getLanguages()` method to get the current list:

```swift
let languages = try await lara.getLanguages()
print("Supported languages: \(languages.joined(separator: ", "))")
```

## ⚙️ Configuration

### Error Handling

The SDK provides detailed error information:

```swift
do {
    let translation = try await lara.translate(text: "Hello", source: "en", target: "fr")
    if let translations = try? translation.translation.getTranslations() {
        print("Translation: \(translations.first ?? "No translation")")
    }
} catch let error as NSError where error.domain == "LaraApiError" {
    print("API Error [\(error.code)]: \(error.localizedDescription)")
    print("Error type: \(error.userInfo["type"] ?? "Unknown")")
} catch {
    print("SDK Error: \(error.localizedDescription)")
}
```

## 📋 Requirements

- Swift 5.5 or higher
- iOS 15.0+, macOS 10.15+, or other supported platforms
- Valid Lara API credentials

## 🧪 Testing

Run the examples to test your setup.

```bash
# All examples use environment variables for credentials, so set them first:
export LARA_ACCESS_KEY_ID="your-access-key-id"
export LARA_ACCESS_KEY_SECRET="your-access-key-secret"
```

```bash
# Run basic text translation example
cd examples
swift run text_translation.swift
```

## 🏗️ Building from Source

```bash
# Clone the repository
git clone https://github.com/translated/lara-swift.git
cd lara-swift

# Build with Swift Package Manager
swift build
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Happy translating! 🌍✨
