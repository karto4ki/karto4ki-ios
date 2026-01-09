//
//  RegistrationInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 09.01.2026.
//

import Foundation

final class RegistrationInteractor {
    
    func goToConfirmation(name: String, username: String, closure: @escaping (Bool) -> Void) {
        AppCoordinator.shared.showRegistrationConfirmation(name: name, username: username, closure: closure)
    }
}
