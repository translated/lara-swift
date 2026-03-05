import Foundation

public enum GlossaryFileFormat: String {
    case csvTableUni = "csv/table-uni"
    case csvTableMulti = "csv/table-multi"

    public init?(rawValue: String) {
        switch rawValue {
        case "csv/table-uni": self = .csvTableUni
        case "csv/table-multi": self = .csvTableMulti
        default: return nil
        }
    }
}