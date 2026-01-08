//
//  SignInProtocols.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 25.12.2025.
//

import Foundation

protocol SignInBusinessLogic {
    func getCode()
    func signInWithApple(userId: String, email: String?, fullName: PersonNameComponents?, identityToken: String?, authorizationCode: String?)
    func appleSignInFailed(_ error: Error)
    func signInWithGoogle(idToken: String?, accessToken: String)
    func googleSignInFailed(_ error: Error)
}

protocol SignInPresentationLogic {
    
}
