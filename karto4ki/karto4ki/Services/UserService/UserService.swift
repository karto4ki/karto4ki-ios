import Foundation

final class UserService: UserServiceProtocol {

    private let sender = Sender.shared
    private let encoder = JSONEncoder()
    private let userDefaultsManager: UserDefaultsManagerProtocol

    init(userDefaultsManager: UserDefaultsManagerProtocol = UserDefaultsManager()) {
        self.userDefaultsManager = userDefaultsManager
    }

    func getMe() async throws -> PrivateUserProfile {
        if let cached = userDefaultsManager.loadPrivateProfile() {
            return cached
        }

        let profile: PrivateUserProfile = try await sender.request(
            endpoint: UserServiceEndpoints.me.rawValue,
            method: .get,
            authenticated: true
        )
        userDefaultsManager.savePrivateProfile(profile)
        return profile
    }

    func updateMe(_ request: UpdateProfileRequest) async throws -> PrivateUserProfile {
        let body = try encoder.encode(request)
        if let payload = String(data: body, encoding: .utf8) {
            print("📤 PUT /me payload: \(payload)")
        }
        let updated: PrivateUserProfile = try await sender.request(
            endpoint: UserServiceEndpoints.me.rawValue,
            method: .put,
            body: body,
            authenticated: true
        )
        userDefaultsManager.savePrivateProfile(updated)
        return updated
    }

    func deleteMe() async throws {
        try await sender.requestVoid(
            endpoint: UserServiceEndpoints.me.rawValue,
            method: .delete,
            authenticated: true
        )
        userDefaultsManager.clearSessionCaches()
    }

    func updateProfilePhoto(photoId: String) async throws -> PrivateUserProfile {
        let body = try encoder.encode(UpdatePhotoRequest(photoId: photoId))
        let updated: PrivateUserProfile = try await sender.request(
            endpoint: UserServiceEndpoints.profilePhoto.rawValue,
            method: .put,
            body: body,
            authenticated: true
        )
        userDefaultsManager.savePrivateProfile(updated)
        return updated
    }

    func deleteProfilePhoto() async throws -> PrivateUserProfile {
        let updated: PrivateUserProfile = try await sender.request(
            endpoint: UserServiceEndpoints.profilePhoto.rawValue,
            method: .delete,
            authenticated: true
        )
        userDefaultsManager.savePrivateProfile(updated)
        return updated
    }

    func getAchievements() async throws -> UserAchievements {
        try await sender.request(
            endpoint: UserServiceEndpoints.achievements.rawValue,
            method: .get,
            authenticated: true
        )
    }

    func getUser(username: String) async throws -> PublicUserProfile {
        try await sender.request(
            endpoint: UserServiceEndpoints.user(username),
            method: .get,
            authenticated: true
        )
    }

    func searchUsers(name: String?, username: String?, offset: Int?, limit: Int?) async throws -> SearchUsersResponse {
        try await sender.request(
            endpoint: UserServiceEndpoints.users(name: name, username: username, offset: offset, limit: limit),
            method: .get,
            authenticated: true
        )
    }

    func checkUsername(_ username: String) async throws -> Bool {
        let response: UsernameExistsResponse = try await sender.request(
            endpoint: UserServiceEndpoints.checkUsername(username),
            method: .get
        )
        return response.userExists
    }
}
