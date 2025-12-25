//
//  SignInAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

struct SignInAssembly {
    static func build() -> SignInViewController {
        let presenter = SignInPresenter()
        let interactor = SignInInteractor(presenter: presenter)
        let view = SignInViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
