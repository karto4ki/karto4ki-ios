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
    
    init(keychain: KeychainManagerProtocol, identityService: IdentityServiceProtocol = MockIdentityService()) {
        self.identityService = identityService
        self.keychainManager = keychain
    }
    
    func sendCodeRequest(request: SendCodeRequest,
                         completion: @escaping (Result<Void, Error>) -> Void) {
        identityService.sendCodeRequest(request,
                                        IdentityServiceEndpoints.signupSendCode.rawValue,
                                        SuccessModels.SendCodeSignupData.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let successResponse):
                    let isSaved = self.keychainManager.save(key: KeychainManager.Keys.signinCode.rawValue,
                                                            value: successResponse.data.signupKey)
                    if isSaved {
                        self.userDefaults.saveEmail(request.email)
                        completion(.success(()))
                    } else {
                        completion(.failure(KeychainManager.KeychainError.saveError))
                    }
                case .failure(let apiError):
                    completion(.failure(apiError))
                }
            }
        }
    }
}
