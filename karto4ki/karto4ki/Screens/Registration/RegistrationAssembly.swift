//
//  RegistrationAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 08.01.2026.
//

import Foundation

struct RegistrationAssembly {
    static func build(identity: IdentityServiceProtocol, keychain: KeychainManagerProtocol, userDefaults: UserDefaultsManagerProtocol) -> RegistrationViewController {
        let worker = RegistrationWorker(identityService: identity, keychainManager: keychain, userDefaults: userDefaults)
        let errorHandler = ErrorHandler(keychainManager: keychain, identityService: identity)
        let interactor = RegistrationInteractor(worker: worker, errorHandler: errorHandler)
        let view = RegistrationViewController(interactor: interactor)
        return view
    }
}
