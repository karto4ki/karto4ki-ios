import Foundation

enum AIServiceEndpoints {

    static let generateFromPDF   = "/api/ai/v1.0/generate-cards-from-pdf"
    static let generateFromDOCX  = "/api/ai/v1.0/generate-cards-from-docx"
    static let generateFromTXT   = "/api/ai/v1.0/generate-cards-from-txt"
    static let generateFromImage = "/api/ai/v1.0/generate-cards-from-image"

    static func taskStatus(_ taskID: String) -> String {
        "/api/ai/v1.0/generate-cards/status/\(taskID)"
    }
}
