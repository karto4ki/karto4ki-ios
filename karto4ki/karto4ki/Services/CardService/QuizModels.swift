import Foundation

struct StartQuizRequestAPI: Encodable {
    let questionCount: Int
    enum CodingKeys: String, CodingKey { case questionCount = "question_count" }
}

struct QuizSessionAPI: Decodable {
    let id: String
    let setId: String
    let questionCount: Int
    let questions: [QuizQuestionAPI]
    enum CodingKeys: String, CodingKey {
        case id, questions
        case setId         = "set_id"
        case questionCount = "question_count"
    }
}

struct QuizQuestionAPI: Decodable {
    let cardId: String
    let front: String
    let back: String
    let options: [QuizOptionAPI]
    let correctIndex: Int
    enum CodingKeys: String, CodingKey {
        case front, back, options
        case cardId       = "card_id"
        case correctIndex = "correct_index"
    }
}

struct QuizOptionAPI: Decodable {
    let id: String
    let text: String
    let isCorrect: Bool
    enum CodingKeys: String, CodingKey {
        case id, text
        case isCorrect = "is_correct"
    }
}

struct SubmitQuizAnswerRequestAPI: Encodable {
    let questionIndex: Int
    let selectedIndex: Int
    let timeSpentMs: Int?
    enum CodingKeys: String, CodingKey {
        case questionIndex = "question_index"
        case selectedIndex = "selected_index"
        case timeSpentMs   = "time_spent_ms"
    }
}

struct QuizAnswerResultAPI: Decodable {
    let questionIndex: Int
    let isCorrect: Bool
    let correctIndex: Int
    let explanation: String?
    enum CodingKeys: String, CodingKey {
        case isCorrect    = "is_correct"
        case correctIndex = "correct_index"
        case explanation
        case questionIndex = "question_index"
    }
}

struct QuizResultAPI: Decodable {
    let sessionId: String
    let totalQuestions: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let scorePercentage: Float
    let timeSpentMs: Int?
    enum CodingKeys: String, CodingKey {
        case sessionId       = "session_id"
        case totalQuestions  = "total_questions"
        case correctAnswers  = "correct_answers"
        case incorrectAnswers = "incorrect_answers"
        case scorePercentage = "score_percentage"
        case timeSpentMs     = "time_spent_ms"
    }
}
