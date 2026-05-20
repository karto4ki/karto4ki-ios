import Foundation

final class AIService {

    static let shared = AIService()
    private init() {}

    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let keychainManager = KeychainManager()

    // MARK: - Public

    /// Uploads a local file to the AI service and returns the generated set_id.
    /// Supports .pdf, .docx, .txt and image files.
    func generateCards(from fileURL: URL) async throws -> String {
        let ext = fileURL.pathExtension.lowercased()
        let endpoint: String
        let mimeType: String

        switch ext {
        case "pdf":
            endpoint = AIServiceEndpoints.generateFromPDF
            mimeType = "application/pdf"
        case "docx":
            endpoint = AIServiceEndpoints.generateFromDOCX
            mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "txt":
            endpoint = AIServiceEndpoints.generateFromTXT
            mimeType = "text/plain"
        case "jpg", "jpeg":
            endpoint = AIServiceEndpoints.generateFromImage
            mimeType = "image/jpeg"
        case "png":
            endpoint = AIServiceEndpoints.generateFromImage
            mimeType = "image/png"
        case "webp":
            endpoint = AIServiceEndpoints.generateFromImage
            mimeType = "image/webp"
        default:
            throw AIServiceError.unsupportedFileType(ext)
        }

        let fileData = try Data(contentsOf: fileURL)
        let filename = fileURL.lastPathComponent

        let boundary = "Boundary-\(UUID().uuidString)"
        let body = buildMultipartBody(
            fileData: fileData,
            filename: filename,
            mimeType: mimeType,
            boundary: boundary,
            fields: ["card_count": "15", "language": "ru", "difficulty": "intermediate"]
        )

        let request = try buildRequest(
            endpoint: endpoint,
            boundary: boundary,
            body: body
        )

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        switch http.statusCode {
        case 200:
            let wrapper = try decoder.decode(SuccessResponse<AISyncResponseAPI>.self, from: data)
            return wrapper.data.setID

        case 202:
            let raw = try JSONDecoder().decode(SuccessResponse<AIAsyncTaskAPI>.self, from: data)
            return try await pollTaskStatus(taskID: raw.data.taskID)

        case 401:
            throw AIServiceError.unauthorized
        default:
            if let apiError = try? decoder.decode(ApiErrorResponse.self, from: data) {
                throw apiError
            }
            throw AIServiceError.serverError(http.statusCode)
        }
    }

    // MARK: - Polling

    private func pollTaskStatus(taskID: String, deadline: Date = Date().addingTimeInterval(300)) async throws -> String {
        while Date() < deadline {
            try await Task.sleep(nanoseconds: 5_000_000_000)
            try Task.checkCancellation()

            let statusRequest = try buildStatusRequest(taskID: taskID)
            let (data, response) = try await session.data(for: statusRequest)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                continue
            }

            let wrapper = try decoder.decode(SuccessResponse<AITaskStatusAPI>.self, from: data)
            let task = wrapper.data

            switch task.status {
            case "completed":
                guard let setID = task.setID, !setID.isEmpty else {
                    throw AIServiceError.generationFailed("Set ID missing in completed task")
                }
                return setID
            case "failed":
                throw AIServiceError.generationFailed(task.error ?? "Unknown error")
            default:
                continue
            }
        }
        throw AIServiceError.timeout
    }

    // MARK: - Request builders

    private func buildRequest(endpoint: String, boundary: String, body: Data) throws -> URLRequest {
        let root = ServerBaseURL.primaryAPIRoot
        let path = endpoint.hasPrefix("/") ? endpoint : "/" + endpoint
        guard let url = URL(string: "\(root)\(path)") else {
            throw AIServiceError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        req.timeoutInterval = 120

        if let token = keychainManager.getString(key: KeychainManager.Keys.accessToken.rawValue) {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }

    private func buildStatusRequest(taskID: String) throws -> URLRequest {
        let root = ServerBaseURL.primaryAPIRoot
        let path = AIServiceEndpoints.taskStatus(taskID)
        guard let url = URL(string: "\(root)\(path)") else {
            throw AIServiceError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 30

        if let token = keychainManager.getString(key: KeychainManager.Keys.accessToken.rawValue) {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }

    // MARK: - Multipart form builder

    private func buildMultipartBody(
        fileData: Data,
        filename: String,
        mimeType: String,
        boundary: String,
        fields: [String: String]
    ) -> Data {
        var body = Data()
        let nl = "\r\n"

        for (name, value) in fields {
            body.appendString("--\(boundary)\(nl)")
            body.appendString("Content-Disposition: form-data; name=\"\(name)\"\(nl)\(nl)")
            body.appendString("\(value)\(nl)")
        }

        body.appendString("--\(boundary)\(nl)")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\(nl)")
        body.appendString("Content-Type: \(mimeType)\(nl)\(nl)")
        body.append(fileData)
        body.appendString("\(nl)--\(boundary)--\(nl)")

        return body
    }
}

// MARK: - Errors

enum AIServiceError: LocalizedError {
    case unsupportedFileType(String)
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case generationFailed(String)
    case timeout

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let ext):
            return "Формат файла \"\(ext)\" не поддерживается. Используйте PDF, DOCX, TXT или изображение."
        case .invalidURL:
            return "Некорректный URL сервера."
        case .invalidResponse:
            return "Некорректный ответ сервера."
        case .unauthorized:
            return "Сессия истекла. Войдите снова."
        case .serverError(let code):
            return "Ошибка сервера (\(code))."
        case .generationFailed(let msg):
            return "Не удалось сгенерировать карточки: \(msg)"
        case .timeout:
            return "Время генерации истекло. Попробуйте позже."
        }
    }
}

// MARK: - Data helper

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
