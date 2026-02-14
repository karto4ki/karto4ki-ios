//
//  CodeInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

import Foundation

final class CodeInteractor: CodeBusinessLogic {
    
    private let presenter: CodePresentationLogic
    private let worker: CodeWorkerLogic
    private let errorHandler: ErrorHandlerLogic
    
    init(presenter: CodePresentationLogic, worker: CodeWorkerLogic, errorHandler: ErrorHandlerLogic) {
        self.presenter = presenter
        self.worker = worker
        self.errorHandler = errorHandler
    }
    
    func sendVerificationRequest(code: String) {
        worker.sendVerificationRequest(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    AppCoordinator.shared.showRegistration()
                }
            case .failure(let error):
                let _ = self.errorHandler.handleError(error)
                DispatchQueue.main.async {
                    // TODO: show error
                }
                print(error.localizedDescription)
            }
        }
    }
}
