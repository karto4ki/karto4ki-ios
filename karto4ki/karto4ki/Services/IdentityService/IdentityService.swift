//
//  IdentityService.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

final class IdentityService: IdentityServiceProtocol {
    
    func sendCodeRequest<Request: Codable, Response: Codable>(_ request: Request,
                                            _ endpoint: String,
                                            _ responseType: Response.Type,
                                            completion: @escaping (Result<SuccessResponse<Response>, any Error>) -> Void) {
        let idempotencyKey = UUID().uuidString
        let body = try? JSONEncoder().encode(request)
        let headers = [
            "Idempotency-Key": idempotencyKey,
            "Content-Type": "application/json"
        ]
        Sender.send(endpoint: endpoint, method: .post, headers: headers, body: body, completion: completion)
    }
    
}
