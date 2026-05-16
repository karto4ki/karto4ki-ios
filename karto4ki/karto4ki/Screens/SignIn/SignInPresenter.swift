//
//  SignInPresenter.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

final class SignInPresenter: SignInPresentationLogic {
    weak var view: SignInDisplayLogic?

    func presentError() {
        view?.hideLoadingOverlay()
    }
}
