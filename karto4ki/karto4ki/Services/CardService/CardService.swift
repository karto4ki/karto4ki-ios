import Foundation

final class CardService: CardServiceProtocol {

    private let sender = Sender.shared
    private let encoder = JSONEncoder()

    // MARK: - Sets

    func getSets(offset: Int? = nil, limit: Int? = nil) async throws -> CardSetsResponseAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockCardSets
        }
        do {
            let response: CardSetsResponseAPI = try await sender.request(
                endpoint: CardServiceEndpoints.sets(offset: offset, limit: limit),
                method: .get,
                authenticated: true
            )
            await LocalDataStore.shared.saveCardSets(response.sets)
            return response
        } catch {
            if isNetworkError(error),
               let cached = await LocalDataStore.shared.loadCardSets() {
                return CardSetsResponseAPI(sets: cached, offset: 0, count: cached.count)
            }
            throw error
        }
    }

    func createSet(_ request: CreateCardSetRequestAPI, idempotencyKey: String) async throws -> CardSetAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockCreatedSet(name: request.name)
        }
        let body = try encoder.encode(request)
        return try await sender.request(
            endpoint: CardServiceEndpoints.sets(),
            method: .post,
            headers: ["Idempotency-Key": idempotencyKey],
            body: body,
            authenticated: true
        )
    }

    func getSet(setId: String) async throws -> CardSetDetailAPI {
        try await sender.request(
            endpoint: CardServiceEndpoints.set(setId),
            method: .get,
            authenticated: true
        )
    }

    func updateSet(setId: String, request: UpdateCardSetRequestAPI) async throws -> CardSetAPI {
        let body = try encoder.encode(request)
        return try await sender.request(
            endpoint: CardServiceEndpoints.set(setId),
            method: .put,
            body: body,
            authenticated: true
        )
    }

    func deleteSet(setId: String) async throws {
        if TestModeManager.shared.isTestMode { return }
        try await sender.requestVoid(
            endpoint: CardServiceEndpoints.set(setId),
            method: .delete,
            authenticated: true
        )
    }

    // MARK: - Cards

    func getCards(setId: String, offset: Int? = nil, limit: Int? = nil) async throws -> CardsResponseAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockCards(for: setId)
        }
        do {
            let response: CardsResponseAPI = try await sender.request(
                endpoint: CardServiceEndpoints.setCards(setId, offset: offset, limit: limit),
                method: .get,
                authenticated: true
            )
            await LocalDataStore.shared.saveCards(response.cards, forSetId: setId)
            return response
        } catch {
            if isNetworkError(error),
               let cached = await LocalDataStore.shared.loadCards(forSetId: setId) {
                return CardsResponseAPI(cards: cached, offset: 0, count: cached.count)
            }
            throw error
        }
    }

    func createCard(setId: String, request: CreateCardRequestAPI, idempotencyKey: String) async throws -> CardAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockCreatedCard(front: request.front, back: request.back, setId: setId)
        }
        let body = try encoder.encode(request)
        return try await sender.request(
            endpoint: CardServiceEndpoints.setCards(setId),
            method: .post,
            headers: ["Idempotency-Key": idempotencyKey],
            body: body,
            authenticated: true
        )
    }

    func getCard(cardId: String) async throws -> CardAPI {
        try await sender.request(
            endpoint: CardServiceEndpoints.card(cardId),
            method: .get,
            authenticated: true
        )
    }

    func updateCard(cardId: String, request: UpdateCardRequestAPI) async throws -> CardAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockCreatedCard(
                front: request.front ?? "", back: request.back ?? "", setId: cardId
            )
        }
        let body = try encoder.encode(request)
        return try await sender.request(
            endpoint: CardServiceEndpoints.card(cardId),
            method: .put,
            body: body,
            authenticated: true
        )
    }

    func deleteCard(cardId: String) async throws {
        if TestModeManager.shared.isTestMode { return }
        try await sender.requestVoid(
            endpoint: CardServiceEndpoints.card(cardId),
            method: .delete,
            authenticated: true
        )
    }

    // MARK: - Study

    func startStudy(setId: String, sessionType: String = "review", limit: Int = 20) async throws -> StudySessionAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockStudySession(for: setId)
        }
        let body = try encoder.encode(StartStudyRequestAPI(sessionType: sessionType, limit: limit))
        return try await sender.request(
            endpoint: CardServiceEndpoints.study(setId),
            method: .post,
            body: body,
            authenticated: true
        )
    }

    func submitAnswer(sessionId: String, cardId: String, isCorrect: Bool, timeSpentMs: Int? = nil) async throws -> AnswerResultAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockAnswerResult(for: cardId)
        }
        let body = try encoder.encode(SubmitAnswerRequestAPI(cardId: cardId, isCorrect: isCorrect, timeSpentMs: timeSpentMs))
        return try await sender.request(
            endpoint: CardServiceEndpoints.studyAnswer(sessionId),
            method: .post,
            body: body,
            authenticated: true
        )
    }

    // MARK: - Statistics

    func getSetStats(setId: String) async throws -> SetStatisticsAPI {
        try await sender.request(
            endpoint: CardServiceEndpoints.setStats(setId),
            method: .get,
            authenticated: true
        )
    }

    func getUserStats() async throws -> UserStatisticsAPI {
        try await sender.request(
            endpoint: CardServiceEndpoints.userStats,
            method: .get,
            authenticated: true
        )
    }

    // MARK: - Search & Clone

    func searchSets(query: String, offset: Int? = nil, limit: Int? = nil) async throws -> SearchSetsResponseAPI {
        try await sender.request(
            endpoint: CardServiceEndpoints.search(query: query, offset: offset, limit: limit),
            method: .get,
            authenticated: true
        )
    }

    func cloneSet(setId: String) async throws -> CardSetAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockCreatedSet(name: "Клонированный набор")
        }
        return try await sender.request(
            endpoint: CardServiceEndpoints.cloneSet(setId),
            method: .post,
            authenticated: true
        )
    }

    // MARK: - Private

    private func isNetworkError(_ error: Error) -> Bool {
        guard case ApiError.networkError = error else { return false }
        return true
    }
}
