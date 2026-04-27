import Foundation

struct FileUploadResponse: Decodable {
    let fileId: String

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
    }
}
