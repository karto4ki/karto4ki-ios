import Foundation

// MARK: - Auth Flow

enum AuthFlow {
    case signIn(signinKey: String)
    case signUp(signupKey: String)
}

// MARK: - Requests

struct SendCodeRequest: Encodable {
    let email: String
}

struct SignInRequest: Encodable {
    let signinKey: String
    let code: String

    enum CodingKeys: String, CodingKey {
        case signinKey = "signin_key"
        case code
    }
}

struct VerifyCodeRequest: Encodable {
    let signupKey: String
    let code: String

    enum CodingKeys: String, CodingKey {
        case signupKey = "signup_key"
        case code
    }
}

struct SignUpRequest: Encodable {
    let signupKey: String
    let name: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case signupKey = "signup_key"
        case name
        case username
    }
}

struct RefreshRequest: Encodable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct OAuthRequest: Encodable {
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

struct SignOutRequest: Encodable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

// MARK: - Responses

struct SendCodeResponse: Decodable {
    let signinKey: String
    let isExisted: Bool

    enum CodingKeys: String, CodingKey {
        case signinKey = "signin_key"
        case isExisted = "is_existed"
    }
}

struct TokensResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
