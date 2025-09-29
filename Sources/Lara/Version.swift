import Foundation

public class Version {

    public static let current: String? = {
        if let versionURL = Bundle.module.url(forResource: "version", withExtension: "txt"),
           let versionData = try? Data(contentsOf: versionURL),
           let versionString = String(data: versionData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !versionString.isEmpty {
            return versionString
        }
        return nil
    }()

    public static func get() -> String? {
        return current
    }
}
