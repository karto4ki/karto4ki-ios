//
//  OnboardingAssembly.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 07.01.2026.
//

import Foundation

struct OnboardingAssembly {
    static func build() -> OnboardingViewController {
        let interactor = OnboardingInteractor()
        let viewController = OnboardingViewController(interactor: interactor)
        return viewController
    }
}
