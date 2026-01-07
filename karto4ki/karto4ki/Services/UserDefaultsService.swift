//
//  UserDefaultsService.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 07.01.2026.
//

import Foundation

struct UserDefaultsService {
    
    private let defaults = UserDefaults.standard
    
    func putOnboardingCompleted() {
        defaults.set(true, forKey: "onboardingCompleted")
    }
    
    func isOnboardingCompleted() -> Bool {
        return defaults.bool(forKey: "onboardingCompleted")
    }
}
