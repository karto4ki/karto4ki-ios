//
//  ContextProtocol.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 17.02.2026.
//

import Foundation

protocol ContextProtocol {
    var keychainManager: KeychainManagerProtocol { get }
    var userDefaults: UserDefaultsManagerProtocol { get }
    var identityService: IdentityServiceProtocol { get }
    var errorHandler: ErrorHandlerProtocol { get }
}
