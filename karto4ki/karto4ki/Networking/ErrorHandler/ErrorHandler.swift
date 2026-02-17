//
//  ErrorHandler.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 12.02.2026.
//

import Foundation

final class ErrorHandler: ErrorHandlerProtocol {
    
    private let serverErrorMessage: String = "Server error."
    private let keychainManager: KeychainManagerProtocol
    private let identityService: IdentityServiceProtocol
    
    init(keychainManager: KeychainManagerProtocol, identityService: IdentityServiceProtocol) {
        self.keychainManager = keychainManager
        self.identityService = identityService
    }
    
    func handleError(_ error: Error) -> ErrorDescription {
        if error is KeychainManager.KeychainError {
            guard let keychainError = error as? KeychainManager.KeychainError else {
                print("Error: Can't handle keychain error")
                return ErrorDescription(message: nil, type: ErrorOutput.None)
            }
            return handleKeychainError(keychainError)
        }
        
        if error is ApiError {
            guard let apiError = error as? ApiError else {
                print("Error: Can't handle api error ")
                return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            }
            return handleApiError(apiError)
        }
        
        if error is ApiErrorResponse {
            guard let apiErrorResponse = error as? ApiErrorResponse else {
                print("Error: Can't handle api error response")
                return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            }
            return handleApiResponseError(apiErrorResponse)
        }
        return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
    }
    
    func handleRefreshTokenError() {
        _ = keychainManager.deleteTokens()
        DispatchQueue.main.async {
            AppCoordinator.shared.showSignIn()
        }
    }
    
    private func handleAccessTokenAbsence() {
        guard let refreshToken = keychainManager.getString(key: KeychainManager.Keys.refreshToken.rawValue) else { return }
        identityService.sendRefreshTokensRequest(RefreshRequest(refreshToken: refreshToken)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let keys):
                _ = self.keychainManager.save(key: KeychainManager.Keys.accessToken.rawValue, value: keys.data.accessToken)
                _ = self.keychainManager.save(key: KeychainManager.Keys.refreshToken.rawValue, value: keys.data.refreshToken)
            case .failure(let failure):
                _ = handleError(failure)
            }
        }
    }
    
    private func handleKeychainError(_ keychainError: KeychainManager.KeychainError) -> ErrorDescription {
        switch keychainError {
        case .saveError:
            print("Error: Saving in keychain storage error")
            
        case .getError:
            print("Error: Getting from keychain storage error")
            
        case .deleteError:
            print("Error: Deleting from keychain storage error")
        }
        return ErrorDescription(message: nil, type: ErrorOutput.None)
    }
    
    private func handleApiError(_ apiError: ApiError) -> ErrorDescription {
        switch apiError {
        case .invalidURL:
            print("Error: The URL is invalid.")
            
        case .networkError(let underlyingError):
            print("Error: Network error occurred. Details: \(underlyingError.localizedDescription)")
            
        case .invalidResponse:
            print("Error: Received an invalid response from the server.")
            
        case .noData:
            print("Error: No data received from the server.")
            
        case .decodingError(let decodingError):
            print("Error: Failed to decode the response. Details: \(decodingError.localizedDescription)")
            
        case .unknown:
            print("Error: An unknown error occurred.")
        }
        return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
    }
    
    private func handleApiResponseError(_ apiResponseError: ApiErrorResponse) -> ErrorDescription {
        switch apiResponseError.errorType {
        case ApiErrorTypes.internalError.rawValue:
            print("Error: Internal server error.")
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            
        case ApiErrorTypes.invalidJson.rawValue:
            print("Error: Invalid JSON received.")
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
        case ApiErrorTypes.validationFailed.rawValue:
            if let details = apiResponseError.errorDetails {
                let detailMessages = details.map { "\($0.field): \($0.message)" }.joined(separator: "\n")
                print("Error: Validation failed:\n\(detailMessages)")
            } else {
                print("Error: Validation failed.")
            }
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            
        case ApiErrorTypes.userNotFound.rawValue:
            print("Error: User not found.")
            return ErrorDescription(message: nil, type: ErrorOutput.None)
            
        case ApiErrorTypes.sendCodeFreqExceeded.rawValue:
            print("Error: Too many requests. Please wait before retrying.")
            return ErrorDescription(message: "You are requesting a code too often", type: ErrorOutput.DisappearingLabel)
            
        case ApiErrorTypes.signinKeyNotFound.rawValue:
            print("Error: Sign-in key not found.")
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            
        case ApiErrorTypes.wrongCode.rawValue:
            print("Error: Incorrect code entered.")
            return ErrorDescription(message: "Incorrect code", type: ErrorOutput.DisappearingLabel)
            
        case ApiErrorTypes.refreshTokenExpired.rawValue:
            print("Error: Session expired. Please log in again.")
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            
        case ApiErrorTypes.refreshTokenInvalidated.rawValue:
            print("Error: Session invalidated. Please log in again.")
            handleRefreshTokenError()
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            
        case ApiErrorTypes.invalidToken.rawValue:
            print("Error: Invalid token provided.")
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            
        case ApiErrorTypes.invalidTokenType.rawValue:
            print("Error: Token type is invalid.")
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
            
        case ApiErrorTypes.userAlreadyExists.rawValue:
            print("Error: User already exists.")
            return ErrorDescription(message: nil, type: ErrorOutput.None)

        default:
            print("Error: An unknown error occurred.")
            return ErrorDescription(message: serverErrorMessage, type: ErrorOutput.Alert)
        }
    }
}
