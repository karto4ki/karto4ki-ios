import Foundation

/// Имитация API (не используется в продакшне, заменена FlashcardStudyRealSession).
/// Оставлена для тестового режима.
final class FlashcardStudyMockSession {

    private let cards: [FlashcardStudyModels.StudyCardPayload]
    private var topCardIndex = 0
    private let total: Int

    init(deckId: UUID, deckTitle: String, deckTotal: Int) {
        _ = deckTitle
        let pool = Self.samplePool
        let sessionTotal = min(max(deckTotal, 1), pool.count)
        self.total = sessionTotal
        self.cards = (0..<sessionTotal).map { i in
            let pair = pool[i % pool.count]
            return FlashcardStudyModels.StudyCardPayload(
                id: "mock-\(deckId.uuidString.prefix(8))-\(i + 1)",
                front: pair.0,
                back: pair.1,
                rememberedCount: 0,
                total: sessionTotal
            )
        }
    }

    func bootstrapDeck() async throws -> FlashcardStudyModels.DeckBootstrap {
        topCardIndex = 0
        guard let top = cards.first else {
            throw NSError(domain: "FlashcardStudyMock", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Пустой набор"])
        }
        let under: FlashcardStudyModels.StudyCardPayload? = cards.count > 1 ? cards[1] : nil
        return FlashcardStudyModels.DeckBootstrap(top: top, under: under)
    }

    func submitDeckAnswer(_ choice: FlashcardStudyModels.RememberChoice) async throws -> FlashcardStudyModels.DeckAdvanceResult {
        let newTopIndex = topCardIndex + 1
        if newTopIndex >= cards.count {
            return .finished(message: "Вы прошли все карточки.")
        }
        topCardIndex = newTopIndex
        let newTop = cards[topCardIndex]
        let prefetchIdx = topCardIndex + 1
        let under: FlashcardStudyModels.StudyCardPayload? = prefetchIdx < cards.count ? cards[prefetchIdx] : nil
        return .continued(newTop: newTop, prefetchedUnder: under)
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
