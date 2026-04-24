import Foundation

final class SignInWorker: SignInWorkerLogic {

    private let identityService: IdentityServiceProtocol
    private let keychainManager: KeychainManagerProtocol
    private let userDefaults: UserDefaultsManagerProtocol

    init(identityService: IdentityServiceProtocol,
         keychainManager: KeychainManagerProtocol,
         userDefaults: UserDefaultsManagerProtocol) {
        self.identityService = identityService
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
    }

    func sendCode(email: String) async throws -> SendCodeResponse {
        let response = try await identityService.sendCode(email: email)
        keychainManager.save(key: KeychainManager.Keys.signinCode.rawValue, value: response.signinKey)
        userDefaults.saveEmail(email)
        return response
    }

    func signInWithGoogle(idToken: String) async throws {
        let tokens = try await identityService.signInWithGoogle(idToken: idToken)
        saveTokens(tokens)
    }

    func signInWithApple(idToken: String) async throws {
        let tokens = try await identityService.signInWithApple(idToken: idToken)
        saveTokens(tokens)
    }

    private func saveTokens(_ tokens: TokensResponse) {
        keychainManager.save(key: KeychainManager.Keys.accessToken.rawValue, value: tokens.accessToken)
        keychainManager.save(key: KeychainManager.Keys.refreshToken.rawValue, value: tokens.refreshToken)
    }
}
