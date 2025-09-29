public class AdaptedToMatches: Codable {
    let matches: [NGMemoryMatch]?
    let matchesList: [[NGMemoryMatch]]?
    
    init(matches: [NGMemoryMatch]){
        self.matches = matches
        self.matchesList = nil
    }
    
    init(matchesList: [[NGMemoryMatch]]){
        self.matches = nil
        self.matchesList = matchesList
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let single = try? container.decode([NGMemoryMatch].self) {
            self.matches = single
            self.matchesList = nil
            return
        }

        if let multiple = try? container.decode([[NGMemoryMatch]].self) {
            self.matches = nil
            self.matchesList = multiple
            return
        }

        self.matches = []
        self.matchesList = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let matches = matches {
            try container.encode(matches)
        } else if let matchesList = matchesList {
            try container.encode(matchesList)
        }
    }
    
    public func getMatches() -> [NGMemoryMatch]? {
        if let matches = matches {
            return matches
        }
        
        return nil
    }
    
    public func getMatchesList() -> [[NGMemoryMatch]]? {
        if let matchesList = matchesList {
            return matchesList
        }
        
        return nil
    }
    
}
