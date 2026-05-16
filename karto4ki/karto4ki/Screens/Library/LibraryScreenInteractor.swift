import Foundation

final class LibraryScreenInteractor: LibraryScreenBusinessLogic {

    private let presenter: LibraryScreenPresentationLogic
    private let cardService: CardServiceProtocol

    init(presenter: LibraryScreenPresentationLogic, cardService: CardServiceProtocol) {
        self.presenter = presenter
        self.cardService = cardService
    }

    // MARK: - Load (cache-first с TTL)

    func loadLibrary() {
        // Если кэш свежий — сразу отдаём данные из LocalDataStore без сетевого запроса
        if !AppCacheStore.setsExpired {
            Task {
                let cached = await LocalDataStore.shared.loadCardSets() ?? []
                let decks = cached.map { LibraryModels.DeckSet(from: $0) }
                presenter.presentDecks(decks)
            }
            return
        }
        fetchFromNetwork()
    }

    // MARK: - Reload (игнорирует TTL — вызывается после создания набора или pull-to-refresh)

    func reloadLibrary() {
        fetchFromNetwork()
    }

    // MARK: - Delete

    func deleteDeck(id: UUID) {
        Task {
            do {
                try await cardService.deleteSet(setId: id.uuidString)
                // deleteSet уже сделал write-through в LocalDataStore и инвалидировал TTL
            } catch {
                // Удаление с сервера провалилось — всё равно отражаем в UI (оптимистичный update был в VC)
            }
            // Перечитываем актуальное состояние из LocalDataStore
            let updated = await LocalDataStore.shared.loadCardSets() ?? []
            let decks = updated.map { LibraryModels.DeckSet(from: $0) }
            presenter.presentDecks(decks)
        }
    }

    // MARK: - Private

    private func fetchFromNetwork() {
        presenter.presentLoading(true)
        Task {
            do {
                let response = try await cardService.getSets(offset: nil, limit: nil)
                // getSets уже сохранил в LocalDataStore и обновил AppCacheStore.setsLastFetchAt
                let decks = response.sets.map { LibraryModels.DeckSet(from: $0) }
                presenter.presentLoading(false)
                presenter.presentDecks(decks)
            } catch {
                // Сетевая ошибка — читаем из LocalDataStore
                let fallback = await LocalDataStore.shared.loadCardSets() ?? []
                let decks = fallback.map { LibraryModels.DeckSet(from: $0) }
                presenter.presentLoading(false)
                presenter.presentDecks(decks)
                if fallback.isEmpty {
                    presenter.presentError("Не удалось загрузить библиотеку")
                }
            }
        }
    }
}
