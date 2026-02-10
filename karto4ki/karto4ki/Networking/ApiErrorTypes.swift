//
//  ApiErrorTypes.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 10.02.2026.
//

import Foundation

enum ApiErrorTypes: String, Codable, Error {
    case invalidJson = "invalid_json"
    case validationFailed = "validation_failed"
    case userNotFound = "user_not_found"
    case sendCodeFreqExceeded = "send_code_freq_exceeded"
    case internalError = "internal"
    case signinKeyNotFound = "signin_key_not_found"
    case wrongCode = "wrong_code"
    case refreshTokenExpired = "refresh_token_expired"
    case refreshTokenInvalidated = "refresh_token_invalidated"
    case invalidTokenType = "invalid_token_type"
    case invalidToken = "invalid_token"
    case wrongToken = "wrong_token"
    case userAlreadyExists = "user_already_exists"
}
