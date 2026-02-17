//
//  Context.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 17.02.2026.
//

import Foundation

final class Context: ContextProtocol {
    var keychainManager: KeychainManagerProtocol
    var userDefaults: UserDefaultsManagerProtocol
    var identityService: IdentityServiceProtocol
    var errorHandler: ErrorHandlerProtocol
    
    init(keychainManager: KeychainManagerProtocol, userDefaults: UserDefaultsManagerProtocol, identityService: IdentityServiceProtocol, errorHandler: ErrorHandlerProtocol) {
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
        self.identityService = identityService
        self.errorHandler = errorHandler
    }
    
}
