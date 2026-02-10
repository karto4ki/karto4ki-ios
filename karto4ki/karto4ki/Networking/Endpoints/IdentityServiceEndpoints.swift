//
//  IdentityServiceEndpoints.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 10.02.2026.
//

import Foundation

enum IdentityServiceEndpoints: String {
    case signinCode = "/api/identity/v1.0/signin/send-email-code"
    case signin = "/api/identity/v1.0/signin"
    case refreshToken = "/api/identity/v1.0/refresh-token"
    case googleAuth = "/api/identity/v1.0/signin/oauth/google"
    case appleAuth = "/api/identity/v1.0/signin/oauth/apple"
    case register = "/api/identity/v1.0/signin/oauth/register"
    case signout = "/api/identity/v1.0/signout"
}
