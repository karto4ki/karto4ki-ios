//
//  CodeInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

final class CodeInteractor: CodeBusinessLogic {
    let presenter: CodePresentationLogic
    
    init(presenter: CodePresentationLogic) {
        self.presenter = presenter
    }
    
    func sendVerificationRequest() {
    }
}
