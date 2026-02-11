//
//  TokenManager.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

final class TokenManager {
    
    private static var lock = NSLock()
    private static var isRefreshing = false
    private static var refreshCompletions: [(Result<SuccessResponse<SuccessModels.Tokens>, Error>) -> Void] = []
    
    static func refreshAccessToken(completion: @escaping (Result<SuccessResponse<SuccessModels.Tokens>, Error>) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        
        if isRefreshing {
            refreshCompletions.append(completion)
            return
        }
        
        isRefreshing = true
        let endpoint = IdentityServiceEndpoints.refreshToken.rawValue
        let idempotencyKey = UUID().uuidString
        
        // TODO: get token from keychain
        let refreshToken: String = ""
        
        let request = RefreshRequest(refreshToken: refreshToken)
        let body = try? JSONEncoder().encode(request)
        
        let headers = [
            "Idempotency-Key": idempotencyKey,
            "Content-Type": "application/json"
        ]
        
        Sender.send(endpoint: endpoint, method: .post, headers: headers, body: body) { result in
            lock.lock()
            defer { lock.unlock() }
            
            for completion in refreshCompletions {
                completion(result)
            }
            
            refreshCompletions.removeAll()
            isRefreshing = false
            
            completion(result)
        }
    }
    
    static func saveTokensToKeychain(tokens: SuccessModels.Tokens) {
        // TODO: save to keychain
    }
}
