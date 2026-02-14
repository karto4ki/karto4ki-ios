//
//  RegistrationWorker.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 15.02.2026.
//

import Foundation

final class RegistrationWorker: RegistrationWorkerLogic {
    
    private let identityService: IdentityServiceProtocol
    private let keychainManager: KeychainManagerProtocol
    private let userDefaultsManager: UserDefaultsManagerProtocol
    
    init(identityService: IdentityServiceProtocol, keychainManager: KeychainManagerProtocol, userDefaults: UserDefaultsManagerProtocol) {
        self.identityService = identityService
        self.keychainManager = keychainManager
        self.userDefaultsManager = userDefaults
    }
    
    func sendSignupRequest(name: String, username: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        #warning("uncomment if use server")
        //        guard let signupCode = keychainManager.getString(key: KeychainManager.Keys.signinCode.rawValue) else {
        //            completion(.failure(ApiError.noData))
        //            return
        //        }
        let signupCode = "dfgh"
        
        let request = SignupRequest(signupKey: signupCode, name: name, username: username)
        
        identityService.sendSignupRequest(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.saveToken(data.data, completion: completion)
                    self.userDefaultsManager.saveName(request.name)
                    self.userDefaultsManager.saveUsername(request.username)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func saveToken(_ successResponse: SuccessModels.Tokens,
                   completion: @escaping (Result<Void, Error>) -> Void) {
        var isSaved = self.keychainManager.save(key: KeychainManager.Keys.accessToken.rawValue,
                                           value: successResponse.accessToken)
        if !isSaved {
            completion(.failure(KeychainManager.KeychainError.saveError))
        }
        
        isSaved = self.keychainManager.save(key: KeychainManager.Keys.refreshToken.rawValue,
                                            value: successResponse.refreshToken)
        
        if isSaved {
            completion(.success(()))
        } else {
            completion(.failure(KeychainManager.KeychainError.saveError))
        }
    }
}
