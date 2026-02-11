//
//  SignInAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

struct SignInAssembly {
    static func build(km: KeychainManagerProtocol) -> SignInViewController {
        let presenter = SignInPresenter()
        let worker = SignInWorker(km: km)
        let interactor = SignInInteractor(presenter: presenter, worker: worker)
        let view = SignInViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
