//
//  SenderProtocols.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 10.02.2026.
//

import Foundation

protocol SenderLogic {
    static func send<T: Codable>(endpoint: String,
                                 method: HTTPMethod,
                                 headers: [String: String]?,
                                 body: Data?,
                                 attempt: Int,
                                 completion: @escaping (Result<SuccessResponse<T>, Error>) -> Void)
}
