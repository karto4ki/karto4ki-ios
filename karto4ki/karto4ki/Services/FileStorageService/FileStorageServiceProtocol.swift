import Foundation

protocol FileStorageServiceProtocol: AnyObject {
    /// Загружает JPEG/PNG как `type=avatar`, возвращает `file_id` для `PUT /me/profile-photo`.
    func uploadAvatarImage(data: Data, fileName: String, mimeType: String) async throws -> String
}
