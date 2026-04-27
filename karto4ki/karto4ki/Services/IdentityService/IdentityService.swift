import Foundation

final class IdentityService: IdentityServiceProtocol {

    private let sender = Sender.shared
    private let encoder = JSONEncoder()

    private func idempotencyHeaders() -> [String: String] {
        ["Idempotency-Key": UUID().uuidString]
    }

    func sendCode(email: String) async throws -> SendCodeResponse {
        let body = try encoder.encode(SendCodeRequest(email: email))
        return try await sender.request(
            endpoint: IdentityServiceEndpoints.sendEmailCode.rawValue,
            method: .post,
            headers: idempotencyHeaders(),
            body: body
        )
    }

    func signIn(signinKey: String, code: String) async throws -> TokensResponse {
        let body = try encoder.encode(SignInRequest(signinKey: signinKey, code: code))
        return try await sender.request(
            endpoint: IdentityServiceEndpoints.signIn.rawValue,
            method: .post,
            headers: idempotencyHeaders(),
            body: body
        )
    }

    func verifyCode(signupKey: String, code: String) async throws {
        let body = try encoder.encode(VerifyCodeRequest(signupKey: signupKey, code: code))
        try await sender.requestVoid(
            endpoint: IdentityServiceEndpoints.verifyCode.rawValue,
            method: .post,
            headers: idempotencyHeaders(),
            body: body
        )
    }

    func signUp(signupKey: String, name: String, username: String) async throws -> TokensResponse {
        let body = try encoder.encode(SignUpRequest(signupKey: signupKey, name: name, username: username))
        return try await sender.request(
            endpoint: IdentityServiceEndpoints.signUp.rawValue,
            method: .post,
            headers: idempotencyHeaders(),
            body: body
        )
    }

    func refreshToken(_ refreshToken: String) async throws -> TokensResponse {
        let body = try encoder.encode(RefreshRequest(refreshToken: refreshToken))
        return try await sender.request(
            endpoint: IdentityServiceEndpoints.refreshToken.rawValue,
            method: .post,
            headers: idempotencyHeaders(),
            body: body
        )
    }

    func signInWithGoogle(idToken: String) async throws -> TokensResponse {
        let body = try encoder.encode(OAuthRequest(idToken: idToken))
        return try await sender.request(
            endpoint: IdentityServiceEndpoints.googleAuth.rawValue,
            method: .post,
            headers: idempotencyHeaders(),
            body: body
        )
    }

    func signInWithApple(idToken: String) async throws -> TokensResponse {
        let body = try encoder.encode(OAuthRequest(idToken: idToken))
        return try await sender.request(
            endpoint: IdentityServiceEndpoints.appleAuth.rawValue,
            method: .post,
            headers: idempotencyHeaders(),
            body: body
        )
    }

    func signOut(refreshToken: String) async throws {
        let body = try encoder.encode(SignOutRequest(refreshToken: refreshToken))
        try await sender.requestVoid(
            endpoint: IdentityServiceEndpoints.signOut.rawValue,
            method: .put,
            headers: [:],
            body: body,
            authenticated: true
        )
    }
}
