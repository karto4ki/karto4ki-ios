import Foundation

enum IdentityServiceEndpoints: String {
    case sendEmailCode = "/api/identity/v1.0/signin/send-email-code"
    case signIn = "/api/identity/v1.0/signin"
    case refreshToken = "/api/identity/v1.0/refresh-token"
    case googleAuth = "/api/identity/v1.0/signin/oath/google"
    case appleAuth = "/api/identity/v1.0/signin/oath/apple"
    case signUp = "/api/identity/v1.0/signup"
    case verifyCode = "/api/identity/v1.0/verify-code"
    case signOut = "/api/identity/sign-out"
}
