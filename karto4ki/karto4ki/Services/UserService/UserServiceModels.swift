import Foundation

// MARK: - Responses

struct PrivateUserProfile: Decodable {
    let id: String
    let name: String
    let username: String
    let email: String?
    let photo: String?
    let createdAt: String?
    let notificationEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, username, email, photo
        case createdAt = "created_at"
        case notificationEnabled = "notification_enabled"
    }
}

struct PublicUserProfile: Decodable {
    let id: String
    let name: String
    let username: String
    let photo: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username, photo
        case createdAt = "created_at"
    }
}

struct UserAchievements: Decodable {
    let sets: Int
    let streak: Int
}

struct SearchUsersResponse: Decodable {
    let users: [PublicUserProfile]
    let offset: Int
    let count: Int
}

struct UsernameExistsResponse: Decodable {
    let userExists: Bool

    enum CodingKeys: String, CodingKey {
        case userExists = "user_exists"
    }
}

// MARK: - Requests

struct UpdateProfileRequest: Encodable {
    let name: String?
    let username: String?
    let notificationEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case name, username
        case notificationEnabled = "notification_enabled"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(notificationEnabled, forKey: .notificationEnabled)
    }
}

struct UpdatePhotoRequest: Encodable {
    let photoId: String

    enum CodingKeys: String, CodingKey {
        case photoId = "photo_id"
    }
}
