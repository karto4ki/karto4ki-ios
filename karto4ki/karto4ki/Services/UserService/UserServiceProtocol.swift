import Foundation

protocol UserServiceProtocol {
    func getMe() async throws -> PrivateUserProfile
    func updateMe(_ request: UpdateProfileRequest) async throws -> PrivateUserProfile
    func deleteMe() async throws
    func updateProfilePhoto(photoId: String) async throws -> PrivateUserProfile
    func deleteProfilePhoto() async throws -> PrivateUserProfile
    func getAchievements() async throws -> UserAchievements
    func getUser(username: String) async throws -> PublicUserProfile
    func searchUsers(name: String?, username: String?, offset: Int?, limit: Int?) async throws -> SearchUsersResponse
    func checkUsername(_ username: String) async throws -> Bool
}
