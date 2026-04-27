import Foundation

final class RegistrationWorker: RegistrationWorkerLogic {

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

    func signUp(name: String, username: String) async throws {
        guard let signupKey = keychainManager.getString(key: KeychainManager.Keys.signinCode.rawValue) else {
            throw ApiError.noData
        }

        let tokens = try await identityService.signUp(signupKey: signupKey, name: name, username: username)

        keychainManager.save(key: KeychainManager.Keys.accessToken.rawValue, value: tokens.accessToken)
        keychainManager.save(key: KeychainManager.Keys.refreshToken.rawValue, value: tokens.refreshToken)

        userDefaults.saveName(name)
        userDefaults.saveUsername(username)
    }
}
