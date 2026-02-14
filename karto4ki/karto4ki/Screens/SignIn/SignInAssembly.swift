//
//  SignInAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

struct SignInAssembly {
    static func build(keychain: KeychainManagerProtocol, identity: IdentityServiceProtocol) -> SignInViewController {
        let presenter = SignInPresenter()
        let worker = SignInWorker(km: keychain)
        let errorHandler = ErrorHandler(keychainManager: keychain, identityService: identity)
        let interactor = SignInInteractor(presenter: presenter, worker: worker, errorHandler: errorHandler)
        let view = SignInViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
