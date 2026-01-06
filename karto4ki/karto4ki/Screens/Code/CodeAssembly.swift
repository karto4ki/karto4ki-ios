//
//  CodeAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

import Foundation

struct CodeAssembly {
    static func build() -> CodeViewController {
        let presenter = CodePresenter()
        let interactor = CodeInteractor(presenter: presenter)
        let view = CodeViewController(interactor: interactor)
        presenter.view = view
        return view
    }
}
