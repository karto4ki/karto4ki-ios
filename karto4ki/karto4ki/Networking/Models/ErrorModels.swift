//
//  ErrorModels.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

struct ApiErrorResponse: Codable, Error {
    let errorType: String
    let errorMessage: String
    let errorDetails: [ErrorDetail]?
    
    enum CodingKeys: String, CodingKey {
        case errorType = "error_type"
        case errorMessage = "error_message"
        case errorDetails = "error_details"
    }
}

struct ErrorDetail: Codable {
    let field: String
    let message: String
}
