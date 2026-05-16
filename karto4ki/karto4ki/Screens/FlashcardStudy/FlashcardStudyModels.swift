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
        /// Сколько карточек уже отмечено «помню» в текущей сессии.
        let rememberedCount: Int
        /// Общее количество карточек в сессии.
        let total: Int
    }

    /// Старт сессии: верхняя карточка + уже загруженная следующая «под колодой».
    struct DeckBootstrap: Equatable {
        let top: StudyCardPayload
        let under: StudyCardPayload?
    }

    /// После ответа:
    /// - `newTop` — карточка, которая теперь на вершине (нужна для «server-first» пути, когда нижний слот был пустым).
    /// - `prefetchedUnder` — карточка под новой верхней (загружается в нижний слот колоды).
    enum DeckAdvanceResult: Equatable {
        case continued(newTop: StudyCardPayload, prefetchedUnder: StudyCardPayload?)
        case finished(message: String)
    }
}
