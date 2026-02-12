//
//  IdentityServiceProtocol.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

protocol IdentityServiceProtocol {
    func sendCodeRequest<Request: Codable, Response: Codable>(_ request: Request,
                                                              _ endpoint: String,
                                                              _ responseType: Response.Type,
                                                              completion: @escaping (Result<SuccessResponse<Response>, Error>) -> Void)
    
    func sendRefreshTokensRequest(_ request: RefreshRequest,
                                  completion: @escaping (Result<SuccessResponse<SuccessModels.Tokens>, Error>) -> Void)
}
