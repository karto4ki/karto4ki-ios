//
//  CodeWorker.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 14.02.2026.
//

import Foundation

final class CodeWorker: CodeWorkerLogic {
    
    private let identityService: IdentityServiceProtocol
    private let keychainManager: KeychainManagerProtocol
    
    init(identityService: IdentityServiceProtocol, keychainManager: KeychainManagerProtocol) {
        self.identityService = identityService
        self.keychainManager = keychainManager
    }
    
    func sendVerificationRequest(code: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        #warning("uncomment if use server")
//        guard let signinCode = keychainManager.getString(key: KeychainManager.Keys.signinCode.rawValue) else {
//            completion(.failure(ApiError.noData))
//            return
//        }
        let signinCode = "dfgh"
        
        let request = CodeModels.VerifyCodeRequest(signupKey: signinCode, code: code)
        
        identityService.sendVerifyCodeRequest(request: request) { [weak self] result in
            guard let _ = self else { return }
            switch result{
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
}
