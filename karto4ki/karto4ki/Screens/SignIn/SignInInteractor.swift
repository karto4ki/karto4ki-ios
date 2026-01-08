//
//  SignInInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

final class SignInInteractor: SignInBusinessLogic {
    private let presenter: SignInPresentationLogic
    
    init(presenter: SignInPresentationLogic) {
        self.presenter = presenter
    }
    
    func getCode() {
        // TODO: getting code
        AppCoordinator.shared.showVerifyCodeScreen()
    }
    
    // TODO: sign in with apple
    func signInWithApple(userId: String, email: String?, fullName: PersonNameComponents?, identityToken: String?, authorizationCode: String?) {}
    func appleSignInFailed(_ error: Error){}
    func signInWithGoogle(idToken: String?, accessToken: String) {}
    func googleSignInFailed(_ error: Error) {}


}
