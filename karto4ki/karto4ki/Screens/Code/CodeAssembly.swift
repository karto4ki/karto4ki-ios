//
//  CodeAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

import Foundation

struct CodeAssembly {
    static func build(context: ContextProtocol) -> CodeViewController {
        let presenter = CodePresenter()
        let worker = CodeWorker(identityService: context.identityService, keychainManager: context.keychainManager)
        let interactor = CodeInteractor(presenter: presenter, worker: worker, errorHandler: context.errorHandler)
        let view = CodeViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
