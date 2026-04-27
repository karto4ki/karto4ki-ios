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

    /// Старт сессии: верхняя карточка + уже загруженная следующая «под колодой».
    struct DeckBootstrap: Equatable {
        let top: StudyCardPayload
        let under: StudyCardPayload?
    }

    /// После ответа: карточка под новой верхней уже на руках; `prefetchedUnder` — следующая под ней (+1 к буферу).
    enum DeckAdvanceResult: Equatable {
        case continued(prefetchedUnder: StudyCardPayload?)
        case finished(message: String)
    }
}
