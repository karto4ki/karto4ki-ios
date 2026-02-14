//
//  CodeInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

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
        AppCoordinator.shared.showRegistration()
    }
}
