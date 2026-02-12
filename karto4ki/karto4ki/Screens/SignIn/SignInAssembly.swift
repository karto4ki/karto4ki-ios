//
//  SignInAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

struct SignInAssembly {
    static func build(km: KeychainManagerProtocol, identity: IdentityServiceProtocol) -> SignInViewController {
        let presenter = SignInPresenter()
        let worker = SignInWorker(km: km)
        let errorHandler = ErrorHandler(keychainManager: km, identityService: identity)
        let interactor = SignInInteractor(presenter: presenter, worker: worker, errorHandler: errorHandler)
        let view = SignInViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
