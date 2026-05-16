import Foundation

/// Реальная сессия: карточки крутятся по кругу пока все не будут отмечены «помню».
/// «Не помню» → карточка уходит в конец пула и вернётся снова.
/// «Помню» → карточка выбывает из пула навсегда.
/// Сессия завершается когда пул опустеет (все карточки отмечены «помню»).
final class FlashcardStudyRealSession {

    private let cardService: CardServiceProtocol
    private let setId: String

    private var sessionId: String = ""
    private var allCards: [CardAPI] = []
    /// Карточки, которые ещё не отмечены «помню» — активный пул повторения.
    private var remainingCards: [CardAPI] = []
    private var rememberedCount: Int = 0

    init(cardService: CardServiceProtocol, setId: String) {
        self.cardService = cardService
        self.setId = setId.lowercased()   // UUID.uuidString возвращает upper-case; бэкенд ожидает lower-case
    }

    // MARK: - Bootstrap

    func bootstrapDeck() async throws -> FlashcardStudyModels.DeckBootstrap {
        // "learn" возвращает все карточки набора без фильтра next_review <= NOW(),
        // что нужно для режима «листать пока все не выучены».
        // "review" фильтрует только просроченные карточки (интервальное повторение).
        let session = try await cardService.startStudy(setId: setId, sessionType: "learn", limit: 50)
        sessionId = session.id
        allCards = session.cards
        remainingCards = session.cards
        rememberedCount = 0

        guard let first = remainingCards.first else {
            throw NSError(
                domain: "FlashcardStudy",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Нет карточек для изучения"]
            )
        }

        let total = allCards.count
        let topPayload = makePayload(for: first, remembered: 0, total: total)
        let underPayload = remainingCards.count > 1
            ? makePayload(for: remainingCards[1], remembered: 0, total: total)
            : nil

        return FlashcardStudyModels.DeckBootstrap(top: topPayload, under: underPayload)
    }

    // MARK: - Submit answer

    func submitDeckAnswer(_ choice: FlashcardStudyModels.RememberChoice) async throws -> FlashcardStudyModels.DeckAdvanceResult {
        guard !sessionId.isEmpty, !remainingCards.isEmpty else {
            throw NSError(domain: "FlashcardStudy", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Сессия не инициализирована"])
        }

        // Синхронно обновляем пул ДО сетевого вызова —
        // это защищает от гонки если пользователь успел свайпнуть снова.
        let currentCard = remainingCards.removeFirst()

        if choice == .dontRemember {
            remainingCards.append(currentCard)   // карточка возвращается в конец
        } else {
            rememberedCount += 1                 // карточка выучена, выбывает из пула
        }

        // Отправляем ответ на сервер
        _ = try await cardService.submitAnswer(
            sessionId: sessionId,
            cardId: currentCard.id,
            isCorrect: choice == .remember,
            timeSpentMs: nil
        )

        // Все выучены?
        if remainingCards.isEmpty {
            return .finished(message: "Отлично! Все карточки выучены! 🎉")
        }

        let total = allCards.count
        // remainingCards[0] — карточка, которая теперь на вершине (была в нижнем слоте или идёт заново)
        let newTopPayload = makePayload(for: remainingCards[0], remembered: rememberedCount, total: total)
        // remainingCards[1] — следующая карточка под верхней (prefetch для нижнего слота)
        let underPayload = remainingCards.count > 1
            ? makePayload(for: remainingCards[1], remembered: rememberedCount, total: total)
            : nil

        return .continued(newTop: newTopPayload, prefetchedUnder: underPayload)
    }

    // MARK: - Private

    private func makePayload(for card: CardAPI, remembered: Int, total: Int) -> FlashcardStudyModels.StudyCardPayload {
        FlashcardStudyModels.StudyCardPayload(
            id: card.id,
            front: card.front,
            back: card.back,
            rememberedCount: remembered,
            total: total
        )
    }
}
