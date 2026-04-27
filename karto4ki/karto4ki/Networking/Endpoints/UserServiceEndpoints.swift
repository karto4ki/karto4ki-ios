import Foundation

enum UserServiceEndpoints: String {
    case me = "/api/user/v1.0/me"
    case profilePhoto = "/api/user/v1.0/me/profile-photo"
    case achievements = "/api/user/v1.0/me/achievements"

    static func user(_ username: String) -> String {
        "/api/user/v1.0/user/\(username)"
    }

    static func users(name: String?, username: String?, offset: Int?, limit: Int?) -> String {
        var components = URLComponents()
        components.path = "/api/user/v1.0/users"
        var items: [URLQueryItem] = []
        if let name { items.append(.init(name: "name", value: name)) }
        if let username { items.append(.init(name: "username", value: username)) }
        if let offset { items.append(.init(name: "offset", value: String(offset))) }
        if let limit { items.append(.init(name: "limit", value: String(limit))) }
        components.queryItems = items.isEmpty ? nil : items
        return components.string ?? "/api/user/v1.0/users"
    }

    static func checkUsername(_ username: String) -> String {
        "/api/user/v1.0/username/\(username)"
    }
}
