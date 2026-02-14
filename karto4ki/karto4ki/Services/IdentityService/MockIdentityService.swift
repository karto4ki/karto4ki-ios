//
//  MockIdentityService.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 14.02.2026.
//

import Foundation

final class MockIdentityService: IdentityServiceProtocol {
    
    func sendCodeRequest<Request: Codable, Response: Codable>(_ request: Request,
                                            _ endpoint: String,
                                            _ responseType: Response.Type,
                                            completion: @escaping (Result<SuccessResponse<Response>, any Error>) -> Void) {
        let json = """
        {
            "data": {
                "signup_key": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
              }
        }
        """
        
        let data = Data(json.utf8)
        
        do {
            let decoded = try JSONDecoder().decode(SuccessResponse<Response>.self, from: data)
            completion(.success(decoded))
        } catch {
            completion(.failure(error))
        }
    }
    
    func sendRefreshTokensRequest(_ request: RefreshRequest,
                                  completion: @escaping (Result<SuccessResponse<SuccessModels.Tokens>, any Error>) -> Void) {
        let endpoint = IdentityServiceEndpoints.refreshToken.rawValue
        let idempotencyKey = UUID().uuidString
        
        let body = try? JSONEncoder().encode(request)
        
        let headers = [
            "Idempotency-Key": idempotencyKey,
            "Content-Type": "application/json"
        ]
        
        Sender.send(endpoint: endpoint, method: .post, headers: headers, body: body, completion: completion)
    }
    
    func sendVerifyCodeRequest(request: VerifyCodeRequest,
                               completion: @escaping (Result<SuccessResponse<SuccessModels.VerifyData>, Error>) -> Void) {
        let json = """
        {
            "data": {
                
              }
        }
        """
        
        let data = Data(json.utf8)
        
        do {
            let decoded = try JSONDecoder().decode(SuccessResponse<SuccessModels.VerifyData>.self, from: data)
            completion(.success(decoded))
        } catch {
            completion(.failure(error))
        }
    }
    
    func sendSignupRequest(_ request: SignupRequest, completion: @escaping (Result<SuccessResponse<SuccessModels.Tokens>, Error>) -> Void) {
        let json = """
        {
              "data": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODlhczAiLCJuYW1lIjoiSm9obiBEZHNvZSIsImlhdCI6MTUxNjIzOTAyMn0.gMtW_LPAMSJXOwU4GhTlnC7tgLI_ILtrr6CQw26U784"
              }
        }
        """
        
        let data = Data(json.utf8)
        
        do {
            let decoded = try JSONDecoder().decode(SuccessResponse<SuccessModels.Tokens>.self, from: data)
            completion(.success(decoded))
        } catch {
            completion(.failure(error))
        }
    }
}
