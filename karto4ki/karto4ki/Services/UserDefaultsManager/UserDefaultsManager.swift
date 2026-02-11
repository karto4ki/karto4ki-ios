//
//  UserDefaultsManager.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 07.01.2026.
//

import Foundation

struct UserDefaultsManager: UserDefaultsManagerProtocol {
    
    private let defaults = UserDefaults.standard
    
    func putOnboardingCompleted() {
        defaults.set(true, forKey: "onboardingCompleted")
    }
    
    func isOnboardingCompleted() -> Bool {
        return defaults.bool(forKey: "onboardingCompleted")
    }
    
    func saveEmail(_ email: String) {
        defaults.set(email, forKey: "email")
    }
}
