import Foundation

// MARK: - Sync response (PDF, image endpoints — HTTP 200)

struct AISyncResponseAPI: Decodable {
    let setID: String
    let setName: String

    enum CodingKeys: String, CodingKey {
        case setID   = "set_id"
        case setName = "set_name"
    }
}

// MARK: - Async task response (DOCX, TXT endpoints — HTTP 202)

struct AIAsyncTaskAPI: Decodable {
    let taskID: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case taskID = "task_id"
        case status
    }
}

// MARK: - Task status polling (GET /status/:task_id — HTTP 200)

struct AITaskStatusAPI: Decodable {
    let taskID: String
    let status: String      // "pending" | "processing" | "completed" | "failed"
    let setID: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case taskID = "task_id"
        case status
        case setID  = "set_id"
        case error
    }
}

