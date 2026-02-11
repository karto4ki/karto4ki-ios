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
    
    init(presenter: SignInPresentationLogic, worker: SignInWorkerLogic) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func getCode(_ email: String) {
        let request = SignInModels.SendCodeRequest(email: email)
        worker.sendCodeRequest(request: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                AppCoordinator.shared.showVerifyCodeScreen()
            case .failure(let error):
                // TODO: handle error
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
