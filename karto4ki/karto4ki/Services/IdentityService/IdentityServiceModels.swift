//
//  IdentityServiceModels.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

struct RefreshRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct SendCodeRequest: Codable {
    let email: String
}

struct VerifyCodeRequest: Codable {
    let signupKey: String
    let code: String
}

struct SignupRequest: Codable {
    let signupKey: String
    let name: String
    let username: String
}
