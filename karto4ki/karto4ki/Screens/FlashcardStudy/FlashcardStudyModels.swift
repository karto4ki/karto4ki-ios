import Foundation

enum FlashcardStudyModels {

    enum RememberChoice: String {
        case remember
        case dontRemember
    }

    struct StudyCardPayload: Equatable {
        let id: String
        let front: String
        let back: String
        /// Позиция в текущей сессии (1…total).
        let position: Int
        let total: Int
    }

    enum NextCardResult: Equatable {
        case card(StudyCardPayload)
        case finished(message: String)
    }
}
