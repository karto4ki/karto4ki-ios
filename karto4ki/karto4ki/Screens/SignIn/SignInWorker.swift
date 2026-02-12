//
//  SignInWorker.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

final class SignInWorker: SignInWorkerLogic {
    private let identityService: IdentityServiceProtocol
    private let keychainManager: KeychainManagerProtocol
    private let userDefaults = UserDefaultsManager()
    
    init(km: KeychainManagerProtocol, identityService: IdentityServiceProtocol = IdentityService()) {
        self.identityService = identityService
        self.keychainManager = km
    }
    
    func sendCodeRequest(request: SignInModels.SendCodeRequest,
                         completion: @escaping (Result<Void, Error>) -> Void) {
        identityService.sendCodeRequest(request,
                                        IdentityServiceEndpoints.signupSendCode.rawValue,
                                        SuccessModels.SendCodeSigninData.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let successResponse):
                    let isSaved = self.keychainManager.save(key: KeychainManager.Keys.signinCode.rawValue,
                                                            value: successResponse.data.signinKey)
                    if isSaved {
                        self.userDefaults.saveEmail(request.email)
                        completion(.success(()))
                    } else {
                        completion(.failure(KeychainManager.KeychainError.saveError))
                    }
                    print("success")
                    completion(.success(()))
                case .failure(let apiError):
                    print("failure")
                    completion(.failure(apiError))
                }
            }
        }
    }
}
