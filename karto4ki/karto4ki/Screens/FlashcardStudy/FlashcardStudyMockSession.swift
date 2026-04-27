import Foundation

/// Имитация `GET/POST` к бэкенду: задержка, очередь карточек, финал «с сервера хватит».
final class FlashcardStudyMockSession {

    private let cards: [FlashcardStudyModels.StudyCardPayload]
    private var currentIndex = 0

    /// Сколько карточек отдать до «сервер сказал хватит» (имитация лимита сессии).
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
        // Имитация ответа сервера «хватит» чуть раньше конца длинной сессии.
        if cards.count >= 8 {
            self.serverLimit = cards.count - 2
        } else {
            self.serverLimit = cards.count
        }
    }

    /// Имитация `GET …/study/session` + первая карточка.
    func fetchInitialCard() async throws -> FlashcardStudyModels.StudyCardPayload {
        try await Self.networkDelay()
        print("🌐 [mock] GET study session → card 1/\(cards.count)")
        currentIndex = 0
        guard let first = cards.first else {
            throw NSError(domain: "FlashcardStudyMock", code: 1, userInfo: [NSLocalizedDescriptionKey: "Пустой набор"])
        }
        return first
    }

    /// Имитация `POST …/study/answer` + ответ с следующей карточкой или `finished`.
    func submitAnswer(_ choice: FlashcardStudyModels.RememberChoice) async throws -> FlashcardStudyModels.NextCardResult {
        try await Self.networkDelay()
        print("🌐 [mock] POST study answer: \(choice.rawValue) (card #\(currentIndex + 1))")

        let nextIndex = currentIndex + 1

        if nextIndex >= serverLimit {
            let messages = [
                "Сервер: на сегодня достаточно.",
                "Сессия завершена. Вернитесь завтра.",
                "Лимит повторений на сегодня исчерпан."
            ]
            return .finished(message: messages[nextIndex % messages.count])
        }

        if nextIndex >= cards.count {
            return .finished(message: "Вы прошли все карточки в этом наборе.")
        }

        currentIndex = nextIndex
        return .card(cards[currentIndex])
    }

    private static func networkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64.random(in: 180_000_000...380_000_000))
    }

    /// Тестовые пары «термин → кратко».
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
