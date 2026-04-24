import Foundation

final class CodeWorker: CodeWorkerLogic {

    private let identityService: IdentityServiceProtocol
    private let keychainManager: KeychainManagerProtocol

    init(identityService: IdentityServiceProtocol, keychainManager: KeychainManagerProtocol) {
        self.identityService = identityService
        self.keychainManager = keychainManager
    }

    func verifyForSignIn(signinKey: String, code: String) async throws {
        let tokens = try await identityService.signIn(signinKey: signinKey, code: code)
        keychainManager.save(key: KeychainManager.Keys.accessToken.rawValue, value: tokens.accessToken)
        keychainManager.save(key: KeychainManager.Keys.refreshToken.rawValue, value: tokens.refreshToken)
    }

    func verifyForSignUp(signupKey: String, code: String) async throws {
        try await identityService.verifyCode(signupKey: signupKey, code: code)
    }
}
