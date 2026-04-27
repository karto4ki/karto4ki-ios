import Foundation

protocol SignInBusinessLogic {
    func getCode(_ email: String)
    func signInWithApple(userId: String, email: String?, fullName: PersonNameComponents?, identityToken: String?, authorizationCode: String?)
    func appleSignInFailed(_ error: Error)
    func signInWithGoogle(idToken: String?, accessToken: String)
    func googleSignInFailed(_ error: Error)
}

protocol SignInPresentationLogic {}

protocol SignInWorkerLogic {
    func sendCode(email: String) async throws -> SendCodeResponse
    func signInWithGoogle(idToken: String) async throws
    func signInWithApple(idToken: String) async throws
}
