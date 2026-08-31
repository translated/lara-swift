enum ShareParameters {
    static func make(name: String?) -> [String: Any] {
        name.map { ["name": $0] } ?? [:]
    }
}
