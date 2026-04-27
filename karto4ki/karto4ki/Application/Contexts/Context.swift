import Foundation

final class Context: ContextProtocol {
    let keychainManager: KeychainManagerProtocol
    let userDefaults: UserDefaultsManagerProtocol
    let identityService: IdentityServiceProtocol
    let userService: UserServiceProtocol
    let fileStorageService: FileStorageServiceProtocol
    let errorHandler: ErrorHandlerProtocol

    init(keychainManager: KeychainManagerProtocol,
         userDefaults: UserDefaultsManagerProtocol,
         identityService: IdentityServiceProtocol,
         userService: UserServiceProtocol,
         fileStorageService: FileStorageServiceProtocol,
         errorHandler: ErrorHandlerProtocol) {
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
        self.identityService = identityService
        self.userService = userService
        self.fileStorageService = fileStorageService
        self.errorHandler = errorHandler
    }
}
