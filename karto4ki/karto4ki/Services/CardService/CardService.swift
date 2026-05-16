import Foundation

final class CardService: CardServiceProtocol {

    private let sender = Sender.shared
    private let encoder = JSONEncoder()
    private let store = LocalDataStore.shared

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
            await store.saveCardSets(response.sets)
            AppCacheStore.setsLastFetchAt = Date()
            return response
        } catch {
            if isNetworkError(error), let cached = await store.loadCardSets() {
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
        let created: CardSetAPI = try await sender.request(
            endpoint: CardServiceEndpoints.sets(),
            method: .post,
            headers: ["Idempotency-Key": idempotencyKey],
            body: body,
            authenticated: true
        )
        // Write-through: добавляем в кэш сразу, инвалидируем TTL чтобы следующий полный fetch был свежим
        await store.appendSet(created)
        AppCacheStore.invalidateSets()
        return created
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
        let updated: CardSetAPI = try await sender.request(
            endpoint: CardServiceEndpoints.set(setId),
            method: .put,
            body: body,
            authenticated: true
        )
        // Write-through: обновляем в кэше
        await store.updateSet(updated)
        AppCacheStore.invalidateSets()
        return updated
    }

    func deleteSet(setId: String) async throws {
        if TestModeManager.shared.isTestMode { return }
        try await sender.requestVoid(
            endpoint: CardServiceEndpoints.set(setId),
            method: .delete,
            authenticated: true
        )
        // Write-through: удаляем из кэша
        await store.deleteSet(setId: setId)
        AppCacheStore.invalidateSets()
        AppCacheStore.invalidateCards(setId: setId)
    }

    // MARK: - Cards

    func getCards(setId: String, offset: Int? = nil, limit: Int? = nil) async throws -> CardsResponseAPI {
        if TestModeManager.shared.isTestMode {
            return TestModeManager.shared.mockCards(for: setId)
        }

        // Cache-First: если данные свежие — отдаём из кэша
        if !AppCacheStore.cardsExpired(setId: setId),
           let cached = await store.loadCards(forSetId: setId),
           !cached.isEmpty {
            return CardsResponseAPI(cards: cached, offset: 0, count: cached.count)
        }

        do {
            let response: CardsResponseAPI = try await sender.request(
                endpoint: CardServiceEndpoints.setCards(setId, offset: offset, limit: limit),
                method: .get,
                authenticated: true
            )
            await store.saveCards(response.cards, forSetId: setId)
            AppCacheStore.markCardsFetched(setId: setId)
            return response
        } catch {
            if isNetworkError(error), let cached = await store.loadCards(forSetId: setId) {
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
        let created: CardAPI = try await sender.request(
            endpoint: CardServiceEndpoints.setCards(setId),
            method: .post,
            headers: ["Idempotency-Key": idempotencyKey],
            body: body,
            authenticated: true
        )
        // Write-through: добавляем карточку в кэш набора
        await store.appendCard(created)
        // Инвалидируем TTL карточек — чтобы следующий полный fetch был свежим
        AppCacheStore.invalidateCards(setId: setId)
        return created
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
        let updated: CardAPI = try await sender.request(
            endpoint: CardServiceEndpoints.card(cardId),
            method: .put,
            body: body,
            authenticated: true
        )
        // Write-through: обновляем карточку в кэше
        await store.updateCard(updated)
        return updated
    }

    func deleteCard(cardId: String) async throws {
        if TestModeManager.shared.isTestMode { return }
        try await sender.requestVoid(
            endpoint: CardServiceEndpoints.card(cardId),
            method: .delete,
            authenticated: true
        )
        // Write-through: удаляем из кэша
        await store.deleteCard(cardId: cardId)
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
        let body = try encoder.encode(SubmitAnswerRequestAPI(cardId: cardId, rating: isCorrect ? 1 : 0, timeSpentMs: timeSpentMs))
        let result: AnswerResultAPI = try await sender.request(
            endpoint: CardServiceEndpoints.studyAnswer(sessionId),
            method: .post,
            body: body,
            authenticated: true
        )
        // Write-through: обновляем статус карточки в кэше
        if let updatedCard = await buildUpdatedCard(cardId: cardId, newStatus: result.newStatus, nextReview: result.nextReview) {
            await store.updateCard(updatedCard)
        }

        return result
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
        let cloned: CardSetAPI = try await sender.request(
            endpoint: CardServiceEndpoints.cloneSet(setId),
            method: .post,
            authenticated: true
        )
        // Write-through: клонированный набор сразу появляется в библиотеке
        await store.appendSet(cloned)
        AppCacheStore.invalidateSets()
        return cloned
    }

    // MARK: - Private

    private func isNetworkError(_ error: Error) -> Bool {
        guard case ApiError.networkError = error else { return false }
        return true
    }

    /// Строим обновлённый CardAPI для write-through после submitAnswer.
    private func buildUpdatedCard(cardId: String, newStatus: String, nextReview: String) async -> CardAPI? {
        guard let old = await store.loadCard(cardId: cardId) else { return nil }
        return CardAPI(
            id: old.id,
            setId: old.setId,
            front: old.front,
            back: old.back,
            imageUrl: old.imageUrl,
            audioUrl: old.audioUrl,
            status: newStatus,
            nextReview: nextReview,
            createdAt: old.createdAt
        )
    }
}
