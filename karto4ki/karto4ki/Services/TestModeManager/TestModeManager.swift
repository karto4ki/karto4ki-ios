import Foundation

final class TestModeManager {
    static let shared = TestModeManager()
    private init() {}

    private let key = "isTestModeEnabled"

    var isTestMode: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            NotificationCenter.default.post(name: .testModeDidChange, object: nil)
        }
    }
}

extension Notification.Name {
    static let testModeDidChange = Notification.Name("TestModeDidChange")
}

// MARK: - Mock data

extension TestModeManager {

    var mockProfile: PrivateUserProfile {
        PrivateUserProfile(
            id: "mock-user-id",
            name: "Алексей Демо",
            username: "demo_user",
            email: "demo@karto4ki.app",
            photo: nil,
            createdAt: "2024-01-15",
            notificationEnabled: true
        )
    }

    private var mockAuthor: AuthorInfoAPI {
        AuthorInfoAPI(id: "mock-user-id", username: "demo_user", name: "Алексей Демо", photo: nil)
    }

    var mockCardSets: CardSetsResponseAPI {
        let sets = [
            CardSetAPI(
                id: "mock-set-1", name: "iOS разработка",
                description: "Основные концепции разработки под iOS",
                cardCount: 15, learnedCount: 7, isPublic: false,
                createdAt: "2025-01-10T10:00:00Z", author: mockAuthor
            ),
            CardSetAPI(
                id: "mock-set-2", name: "Алгоритмы",
                description: "Алгоритмы и структуры данных",
                cardCount: 10, learnedCount: 3, isPublic: false,
                createdAt: "2025-02-20T10:00:00Z", author: mockAuthor
            ),
            CardSetAPI(
                id: "mock-set-3", name: "Swift основы",
                description: "Базовый синтаксис Swift",
                cardCount: 12, learnedCount: 12, isPublic: true,
                createdAt: "2025-03-05T10:00:00Z", author: mockAuthor
            ),
            CardSetAPI(
                id: "mock-set-4", name: "Design Patterns",
                description: "Паттерны проектирования",
                cardCount: 8, learnedCount: 2, isPublic: false,
                createdAt: "2025-04-01T10:00:00Z", author: mockAuthor
            ),
        ]
        return CardSetsResponseAPI(sets: sets, offset: 0, count: sets.count)
    }

    func mockCards(for setId: String) -> CardsResponseAPI {
        let pairs: [(String, String)] = [
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
        ]
        let cards = pairs.enumerated().map { idx, pair in
            CardAPI(
                id: "mock-card-\(setId)-\(idx + 1)",
                setId: setId,
                front: pair.0,
                back: pair.1,
                imageUrl: nil,
                audioUrl: nil,
                status: "new",
                nextReview: nil,
                createdAt: "2025-01-15T10:00:00Z"
            )
        }
        return CardsResponseAPI(cards: cards, offset: 0, count: cards.count)
    }

    func mockStudySession(for setId: String) -> StudySessionAPI {
        StudySessionAPI(
            id: "mock-session-\(setId)",
            setId: setId,
            cards: mockCards(for: setId).cards,
            sessionType: "review"
        )
    }

    func mockAnswerResult(for cardId: String) -> AnswerResultAPI {
        AnswerResultAPI(cardId: cardId, newStatus: "learned", nextReview: ISO8601DateFormatter().string(from: Date()), streak: 1, errorCount: 0, lastRating: 1)
    }



    func mockCreatedSet(name: String) -> CardSetAPI {
        CardSetAPI(
            id: "mock-set-new-\(UUID().uuidString)",
            name: name,
            description: nil,
            cardCount: 0, learnedCount: 0, isPublic: false,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            author: mockAuthor
        )
    }

    func mockCreatedCard(front: String, back: String, setId: String) -> CardAPI {
        CardAPI(
            id: "mock-card-new-\(UUID().uuidString)",
            setId: setId,
            front: front,
            back: back,
            imageUrl: nil,
            audioUrl: nil,
            status: "new",
            nextReview: nil,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func mockStudySessionAll() -> StudySessionAPI {
        StudySessionAPI(
            id: "mock-session-all",
            setId: nil,
            cards: mockCards(for: "mock-set-1").cards + mockCards(for: "mock-set-2").cards,
            sessionType: "learn"
        )
    }

}
