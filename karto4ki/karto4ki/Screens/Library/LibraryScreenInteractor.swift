import Foundation

/// Минимальный интервал между «запросами к серверу» (пока мок).
private let libraryFetchThrottle: TimeInterval = 180

final class LibraryScreenInteractor: LibraryScreenBusinessLogic {

    private let presenter: LibraryScreenPresentationLogic

    init(presenter: LibraryScreenPresentationLogic) {
        self.presenter = presenter
    }

    func loadLibrary() {
        presenter.presentLoading(true)

        Task {
            let now = Date()

            if let last = LibraryCacheStore.lastFetchAt,
               now.timeIntervalSince(last) < libraryFetchThrottle,
               let cached = LibraryCacheStore.loadDecks(),
               !cached.isEmpty {
                presenter.presentDecks(cached)
                return
            }

            do {
                let fresh = try await Self.mockNetworkFetch()
                LibraryCacheStore.saveDecks(fresh)
                LibraryCacheStore.lastFetchAt = now
                presenter.presentDecks(fresh)
            } catch {
                let fallback = LibraryCacheStore.loadDecks() ?? []
                presenter.presentDecks(fallback)
            }
        }
    }

    func deleteDeck(id: UUID) {
        var list = LibraryCacheStore.loadDecks() ?? []
        list.removeAll { $0.id == id }
        LibraryCacheStore.saveDecks(list)
        presenter.presentDecks(list)
    }

    /// Имитация сети: задержка и редкий сбой (тогда UI возьмёт кэш).
    private static func mockNetworkFetch() async throws -> [LibraryModels.DeckSet] {
        try await Task.sleep(nanoseconds: 350_000_000)
        if Double.random(in: 0...1) < 0.08 {
            throw URLError(.cannotConnectToHost)
        }
        return Self.defaultMockDecks()
    }

    private static func defaultMockDecks() -> [LibraryModels.DeckSet] {
        let cal = Calendar.current
        let now = Date()
        return [
            LibraryModels.DeckSet(
                id: UUID(),
                title: "Английский. Основы",
                learned: 120,
                total: 320,
                addedAt: cal.date(byAdding: .hour, value: -2, to: now) ?? now,
                colorIndex: 0
            ),
            LibraryModels.DeckSet(
                id: UUID(),
                title: "Немецкий. А1",
                learned: 45,
                total: 200,
                addedAt: cal.date(byAdding: .day, value: -1, to: now) ?? now,
                colorIndex: 1
            ),
            LibraryModels.DeckSet(
                id: UUID(),
                title: "Испанский. Фразы",
                learned: 12,
                total: 80,
                addedAt: cal.date(byAdding: .day, value: -3, to: now) ?? now,
                colorIndex: 2
            ),
            LibraryModels.DeckSet(
                id: UUID(),
                title: "Японский. Кана",
                learned: 0,
                total: 46,
                addedAt: cal.date(byAdding: .day, value: -7, to: now) ?? now,
                colorIndex: 3,
                isUserOwned: false
            )
        ]
    }
}
