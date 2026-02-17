//
//  RegistrationAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 08.01.2026.
//

import Foundation

struct RegistrationAssembly {
    static func build(context: ContextProtocol) -> RegistrationViewController {
        let worker = RegistrationWorker(identityService: context.identityService,
                                        keychainManager: context.keychainManager,
                                        userDefaults: context.userDefaults)
        let interactor = RegistrationInteractor(worker: worker, errorHandler: context.errorHandler)
        let view = RegistrationViewController(interactor: interactor)
        return view
    }
}
