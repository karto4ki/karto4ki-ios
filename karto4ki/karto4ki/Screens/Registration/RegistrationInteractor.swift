//
//  RegistrationInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 09.01.2026.
//

import Foundation

final class RegistrationInteractor: RegistrationBusinessLogic {
    
    private let worker: RegistrationWorkerLogic
    private let errorHandler: ErrorHandlerLogic
    
    init(worker: RegistrationWorkerLogic, errorHandler: ErrorHandlerLogic) {
        self.worker = worker
        self.errorHandler = errorHandler
    }

    func goToConfirmation(name: String, username: String, goBackClosure: @escaping (Bool) -> Void?, routingClosure: @escaping (String, String) -> Void?) {
        AppCoordinator.shared.showRegistrationConfirmation(name: name, username: username, goBackClosure: goBackClosure, routingClosure: routingClosure)
    }
    
    func confirm(name: String, username: String) {
        worker.sendSignupRequest(name: name, username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                // TODO: routing to next screen
                AppCoordinator.shared.showOnboarding()
            case .failure(let error):
                let _ = errorHandler.handleError(error)
                // TODO: show an error
            }
            
        }
    }
}
