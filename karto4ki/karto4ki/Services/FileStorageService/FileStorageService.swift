import Foundation

final class FileStorageService: FileStorageServiceProtocol {

    private let sender = Sender.shared

    func uploadAvatarImage(data: Data, fileName: String, mimeType: String) async throws -> String {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        func appendLine(_ s: String) { body.append(Data(s.utf8)) }

        appendLine("--\(boundary)\r\n")
        appendLine("Content-Disposition: form-data; name=\"type\"\r\n\r\n")
        appendLine("avatar\r\n")

        appendLine("--\(boundary)\r\n")
        appendLine("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
        appendLine("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        appendLine("\r\n")
        appendLine("--\(boundary)--\r\n")

        let response: FileUploadResponse = try await sender.requestMultipart(
            endpoint: FileStorageEndpoints.upload.rawValue,
            method: .post,
            multipartBody: body,
            boundary: boundary,
            authenticated: true
        )
        return response.fileId
    }
}
