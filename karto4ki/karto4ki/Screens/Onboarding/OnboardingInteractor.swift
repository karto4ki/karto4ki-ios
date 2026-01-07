//
//  OnboardingInteractor.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 07.01.2026.
//

import Foundation

struct OnboardingInteractor: OnboardingBussinessLogic {
    
    private let userDefaults = UserDefaultsService()

    func routingToSignIn() {
        userDefaults.putOnboardingCompleted()
        AppCoordinator.shared.showRegistration()
    }
}
