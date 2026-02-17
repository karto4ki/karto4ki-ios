//
//  SignInAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

struct SignInAssembly {
    static func build(context: ContextProtocol) -> SignInViewController {
        let presenter = SignInPresenter()
        let worker = SignInWorker(keychain: context.keychainManager)
        let interactor = SignInInteractor(presenter: presenter, worker: worker, errorHandler: context.errorHandler)
        let view = SignInViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
