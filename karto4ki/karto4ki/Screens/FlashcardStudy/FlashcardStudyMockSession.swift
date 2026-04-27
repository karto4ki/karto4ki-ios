import Foundation

/// Имитация API: при старте два GET (текущая + следующая), после каждого POST — ещё один GET на карту «под колодой».
final class FlashcardStudyMockSession {

    private let cards: [FlashcardStudyModels.StudyCardPayload]
    private var topCardIndex = 0

    private let serverLimit: Int

    init(deckId: UUID, deckTitle: String, deckTotal: Int) {
        _ = deckId
        _ = deckTitle
        let pool = Self.samplePool
        let sessionTotal = min(max(deckTotal, 1), pool.count)
        self.cards = (0..<sessionTotal).map { i in
            let pair = pool[i % pool.count]
            return FlashcardStudyModels.StudyCardPayload(
                id: "mock-\(deckId.uuidString.prefix(8))-\(i + 1)",
                front: pair.0,
                back: pair.1,
                position: i + 1,
                total: sessionTotal
            )
        }
        if cards.count >= 8 {
            self.serverLimit = cards.count - 2
        } else {
            self.serverLimit = cards.count
        }
    }

    /// Два последовательных «запроса»: текущая карточка и следующая под колодой.
    func bootstrapDeck() async throws -> FlashcardStudyModels.DeckBootstrap {
        try await Self.networkDelay()
        print("🌐 [mock] GET study card #1 (current)")
        try await Self.networkDelay()
        print("🌐 [mock] GET study card #2 (prefetch under)")
        topCardIndex = 0
        guard let top = cards.first else {
            throw NSError(domain: "FlashcardStudyMock", code: 1, userInfo: [NSLocalizedDescriptionKey: "Пустой набор"])
        }
        let under: FlashcardStudyModels.StudyCardPayload? = cards.count > 1 ? cards[1] : nil
        return FlashcardStudyModels.DeckBootstrap(top: top, under: under)
    }

    /// POST ответа + GET следующей карты для нижнего слоя колоды.
    func submitDeckAnswer(_ choice: FlashcardStudyModels.RememberChoice) async throws -> FlashcardStudyModels.DeckAdvanceResult {
        try await Self.networkDelay()
        print("🌐 [mock] POST study answer: \(choice.rawValue) (top was #\(topCardIndex + 1))")

        let newTopIndex = topCardIndex + 1

        if newTopIndex >= serverLimit {
            let messages = [
                "Сервер: на сегодня достаточно.",
                "Сессия завершена. Вернитесь завтра.",
                "Лимит повторений на сегодня исчерпан."
            ]
            return .finished(message: messages[newTopIndex % messages.count])
        }

        if newTopIndex >= cards.count {
            return .finished(message: "Вы прошли все карточки в этом наборе.")
        }

        topCardIndex = newTopIndex

        try await Self.networkDelay()
        print("🌐 [mock] GET study card (prefetch under after swipe)")

        let prefetchIdx = topCardIndex + 1
        let prefetchedUnder: FlashcardStudyModels.StudyCardPayload? = (prefetchIdx < cards.count) ? cards[prefetchIdx] : nil

        return .continued(prefetchedUnder: prefetchedUnder)
    }

    private static func networkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64.random(in: 180_000_000...380_000_000))
    }

    private static let samplePool: [(String, String)] = [
        ("диспетчеризация", "Планирование и передача работ между потоками/очередями"),
        ("идемпотентность", "Повторный запрос даёт тот же результат, что и первый"),
        ("декоратор", "Оборачивает объект, добавляя поведение без изменения интерфейса"),
        ("мемоизация", "Кэширование результата функции по аргументам"),
        ("race condition", "Ошибка из‑за недетерминированного порядка доступа к данным"),
        ("инверсия зависимостей", "Модули верхнего уровня не зависят от деталей нижнего"),
        ("чистая функция", "Без побочных эффектов, результат только от входа"),
        ("замыкание", "Функция + захваченное окружение из лексической области"),
        ("каррирование", "Превращение f(a,b) в f(a)(b)"),
        ("debounce", "Откладывать вызов, пока не пауза между событиями"),
        ("throttle", "Ограничение частоты вызовов по времени"),
        ("CQRS", "Разделение команд записи и запросов чтения"),
        ("event sourcing", "Хранение последовательности событий вместо только состояния"),
        ("CAP-теорема", "Consistency / Availability / Partition tolerance — выбор двух из трёх"),
        ("REST", "Ресурсы + HTTP-методы + статус-коды")
    ]
}
