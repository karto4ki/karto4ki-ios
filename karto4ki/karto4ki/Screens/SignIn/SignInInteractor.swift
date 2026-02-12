//
//  SignInInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

final class SignInInteractor: SignInBusinessLogic {
    private let presenter: SignInPresentationLogic
    private let worker: SignInWorkerLogic
    private let errorHandler: ErrorHandlerLogic
    
    init(presenter: SignInPresentationLogic, worker: SignInWorkerLogic, errorHandler: ErrorHandlerLogic) {
        self.presenter = presenter
        self.worker = worker
        self.errorHandler = errorHandler
    }
    
    func getCode(_ email: String) {
        let request = SignInModels.SendCodeRequest(email: email)
        worker.sendCodeRequest(request: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                AppCoordinator.shared.showVerifyCodeScreen()
            case .failure(let error):
                let errorId = self.errorHandler.handleError(error)
                // TODO: show error message to user
                print(error.localizedDescription)
            }
        }
    }
    
    // TODO: sign in with apple
    func signInWithApple(userId: String, email: String?, fullName: PersonNameComponents?, identityToken: String?, authorizationCode: String?) {
        AppCoordinator.shared.showRegistration()
    }
    func appleSignInFailed(_ error: Error){}
    func signInWithGoogle(idToken: String?, accessToken: String) {
        AppCoordinator.shared.showRegistration()
    }
    func googleSignInFailed(_ error: Error) {}


}
