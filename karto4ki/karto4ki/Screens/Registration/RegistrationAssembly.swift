//
//  RegistrationAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 08.01.2026.
//

import Foundation

struct RegistrationAssembly {
    static func build() -> RegistrationViewController {
        let interactor = RegistrationInteractor()
        let view = RegistrationViewController(interactor: interactor)
        return view
    }
}
