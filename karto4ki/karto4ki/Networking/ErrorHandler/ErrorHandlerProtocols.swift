//
//  ErrorHandlerProtocols.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 12.02.2026.
//

import Foundation

protocol ErrorHandlerProtocol {
    func handleError(_ error: Error) -> ErrorDescription
    func handleRefreshTokenError()
}
