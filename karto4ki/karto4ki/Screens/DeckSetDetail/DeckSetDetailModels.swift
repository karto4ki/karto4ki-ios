import Foundation

enum DeckSetDetailModels {

    struct FlashcardRow: Equatable, Identifiable {
        /// Локальный идентификатор для UI (answerHidden, rebuildCardRows).
        let id: UUID
        /// Реальный строковый ID с сервера.
        var apiId: String
        var question: String
        var answer: String
        /// Статус карточки с сервера: "new", "learning", "reviewing", "mastered".
        var status: String

        /// Карточка считается изученной если статус "reviewing" или "mastered".
        var isLearned: Bool { status == "reviewing" || status == "mastered" }

        init(from api: CardAPI) {
            id = UUID()
            apiId = api.id
            question = api.front
            answer = api.back
            status = api.status
        }

        /// Используется только для добавления локальной карточки до получения ответа сервера.
        init(apiId: String, question: String, answer: String) {
            id = UUID()
            self.apiId = apiId
            self.question = question
            self.answer = answer
            status = "new"
        }
    }
}
