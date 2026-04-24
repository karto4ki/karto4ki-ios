import Foundation

actor TokenManager {

    static let shared = TokenManager()

    private var refreshTask: Task<Void, Error>?
    private let keychainManager = KeychainManager()

    func refreshTokens() async throws {
        if let existing = refreshTask {
            try await existing.value
            return
        }

        let task = Task<Void, Error> { [keychainManager] in
            guard let refreshToken = keychainManager.getString(
                key: KeychainManager.Keys.refreshToken.rawValue
            ) else {
                throw ApiErrorResponse(
                    errorType: "refresh_token_expired",
                    errorMessage: "No refresh token in keychain",
                    errorDetails: nil
                )
            }

            let body = try JSONEncoder().encode(RefreshRequest(refreshToken: refreshToken))
            let headers = ["Idempotency-Key": UUID().uuidString]

            let tokens: TokensResponse = try await Sender.shared.request(
                endpoint: IdentityServiceEndpoints.refreshToken.rawValue,
                method: .post,
                headers: headers,
                body: body
            )

            keychainManager.save(key: KeychainManager.Keys.accessToken.rawValue, value: tokens.accessToken)
            keychainManager.save(key: KeychainManager.Keys.refreshToken.rawValue, value: tokens.refreshToken)
        }

        refreshTask = task
        defer { refreshTask = nil }
        try await task.value
    }
}
