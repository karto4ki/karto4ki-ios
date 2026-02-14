//
//  CodeAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

import Foundation

struct CodeAssembly {
    static func build(keychain: KeychainManagerProtocol, identity: IdentityServiceProtocol) -> CodeViewController {
        let presenter = CodePresenter()
        let worker = CodeWorker(identityService: identity, keychainManager: keychain)
        let errorHandler = ErrorHandler(keychainManager: keychain, identityService: identity)
        let interactor = CodeInteractor(presenter: presenter, worker: worker, errorHandler: errorHandler)
        let view = CodeViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
