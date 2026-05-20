import Foundation

protocol CardServiceProtocol {
    func getSets(offset: Int?, limit: Int?) async throws -> CardSetsResponseAPI
    func createSet(_ request: CreateCardSetRequestAPI, idempotencyKey: String) async throws -> CardSetAPI
    func getSet(setId: String) async throws -> CardSetDetailAPI
    func updateSet(setId: String, request: UpdateCardSetRequestAPI) async throws -> CardSetAPI
    func deleteSet(setId: String) async throws

    func getCards(setId: String, offset: Int?, limit: Int?) async throws -> CardsResponseAPI
    func createCard(setId: String, request: CreateCardRequestAPI, idempotencyKey: String) async throws -> CardAPI
    func getCard(cardId: String) async throws -> CardAPI
    func updateCard(cardId: String, request: UpdateCardRequestAPI) async throws -> CardAPI
    func deleteCard(cardId: String) async throws

    func startStudy(setId: String, sessionType: String, limit: Int) async throws -> StudySessionAPI
    func submitAnswer(sessionId: String, cardId: String, isCorrect: Bool, timeSpentMs: Int?) async throws -> AnswerResultAPI

    func getSetStats(setId: String) async throws -> SetStatisticsAPI
    func getUserStats() async throws -> UserStatisticsAPI

    func searchSets(query: String, offset: Int?, limit: Int?) async throws -> SearchSetsResponseAPI
    func cloneSet(setId: String) async throws -> CardSetAPI

    func startStudyAll(sessionType: String, limit: Int) async throws -> StudySessionAPI
}
