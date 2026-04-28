import Foundation

public class ProfanitiesValue: Codable {
    private let single: ProfanityDetectResult?
    private let list: [ProfanityDetectResult?]?

    public init(single: ProfanityDetectResult) {
        self.single = single
        self.list = nil
    }

    public init(list: [ProfanityDetectResult?]) {
        self.single = nil
        self.list = list
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let singleResult = try? container.decode(ProfanityDetectResult.self) {
            self.single = singleResult
            self.list = nil
            return
        }

        if let listResult = try? container.decode([ProfanityDetectResult?].self) {
            self.single = nil
            self.list = listResult
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "ProfanitiesValue must decode as a ProfanityDetectResult object or an array of ProfanityDetectResult"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let single = single {
            try container.encode(single)
        } else if let list = list {
            try container.encode(list)
        }
    }

    public func getSingle() -> ProfanityDetectResult? {
        return single
    }

    public func getList() -> [ProfanityDetectResult?]? {
        return list
    }
}
