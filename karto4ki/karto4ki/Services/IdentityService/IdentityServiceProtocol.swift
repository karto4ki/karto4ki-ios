import Foundation

protocol IdentityServiceProtocol {
    func sendCode(email: String) async throws -> SendCodeResponse
    func signIn(signinKey: String, code: String) async throws -> TokensResponse
    func verifyCode(signupKey: String, code: String) async throws
    func signUp(signupKey: String, name: String, username: String) async throws -> TokensResponse
    func refreshToken(_ refreshToken: String) async throws -> TokensResponse
    func signInWithGoogle(idToken: String) async throws -> TokensResponse
    func signInWithApple(idToken: String) async throws -> TokensResponse
    func signOut(refreshToken: String) async throws
}
