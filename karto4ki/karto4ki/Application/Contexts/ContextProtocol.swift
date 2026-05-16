import Foundation

protocol ContextProtocol {
    var keychainManager: KeychainManagerProtocol { get }
    var userDefaults: UserDefaultsManagerProtocol { get }
    var identityService: IdentityServiceProtocol { get }
    var userService: UserServiceProtocol { get }
    var fileStorageService: FileStorageServiceProtocol { get }
    var cardService: CardServiceProtocol { get }
    var errorHandler: ErrorHandlerProtocol { get }
}
