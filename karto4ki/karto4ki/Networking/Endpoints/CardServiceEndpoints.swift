import Foundation

enum CardServiceEndpoints {

    static let userStats = "/api/card/v1.0/me/stats"

    static func sets(offset: Int? = nil, limit: Int? = nil) -> String {
        var components = URLComponents()
        components.path = "/api/card/v1.0/sets"
        var items: [URLQueryItem] = []
        if let offset { items.append(.init(name: "offset", value: String(offset))) }
        if let limit  { items.append(.init(name: "limit",  value: String(limit)))  }
        components.queryItems = items.isEmpty ? nil : items
        return components.string ?? "/api/card/v1.0/sets"
    }

    static func set(_ setId: String) -> String { "/api/card/v1.0/sets/\(setId)" }

    static func setCards(_ setId: String, offset: Int? = nil, limit: Int? = nil) -> String {
        var components = URLComponents()
        components.path = "/api/card/v1.0/sets/\(setId)/cards"
        var items: [URLQueryItem] = []
        if let offset { items.append(.init(name: "offset", value: String(offset))) }
        if let limit  { items.append(.init(name: "limit",  value: String(limit)))  }
        components.queryItems = items.isEmpty ? nil : items
        return components.string ?? "/api/card/v1.0/sets/\(setId)/cards"
    }

    static func card(_ cardId: String) -> String { "/api/card/v1.0/cards/\(cardId)" }

    static func study(_ setId: String) -> String { "/api/card/v1.0/sets/\(setId)/study" }

    static func studyAnswer(_ sessionId: String) -> String { "/api/card/v1.0/study/\(sessionId)/answer" }

    static func setStats(_ setId: String) -> String { "/api/card/v1.0/sets/\(setId)/stats" }

    static func cloneSet(_ setId: String) -> String { "/api/card/v1.0/sets/\(setId)/clone" }

    static func search(query: String, offset: Int? = nil, limit: Int? = nil) -> String {
        var components = URLComponents()
        components.path = "/api/card/v1.0/search"
        var items: [URLQueryItem] = [.init(name: "query", value: query)]
        if let offset { items.append(.init(name: "offset", value: String(offset))) }
        if let limit  { items.append(.init(name: "limit",  value: String(limit)))  }
        components.queryItems = items
        return components.string ?? "/api/card/v1.0/search"
    }
}
