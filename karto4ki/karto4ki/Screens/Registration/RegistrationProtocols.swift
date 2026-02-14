//
//  RegistrationProtocols.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 14.02.2026.
//

import Foundation

protocol RegistrationBusinessLogic {
    func confirm(name: String, username: String)
    func goToConfirmation(name: String,
                          username: String,
                          goBackClosure: @escaping (Bool) -> Void?,
                          routingClosure: @escaping (String, String) -> Void?)
}

protocol RegistrationWorkerLogic {
    func sendSignupRequest(name: String, username: String,
                           completion: @escaping (Result<Void, Error>) -> Void)
}
