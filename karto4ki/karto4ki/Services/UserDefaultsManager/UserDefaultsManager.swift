//
//  UserDefaultsManager.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 07.01.2026.
//

import Foundation

struct UserDefaultsManager: UserDefaultsManagerProtocol {

    private let defaults = UserDefaults.standard
    private let profileKey = "privateUserProfile"
    
    func putOnboardingCompleted() {
        defaults.set(true, forKey: "onboardingCompleted")
    }
    
    func isOnboardingCompleted() -> Bool {
        return defaults.bool(forKey: "onboardingCompleted")
    }
    
    func saveEmail(_ email: String) {
        defaults.set(email, forKey: "email")
    }
    
    func saveName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "name")
    }
    
    func saveUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: "username")
    }

    func savePrivateProfile(_ profile: PrivateUserProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: profileKey)
    }

    func loadPrivateProfile() -> PrivateUserProfile? {
        guard let data = defaults.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(PrivateUserProfile.self, from: data)
    }

    func clearSessionCaches() {
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "name")
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: profileKey)
    }
}
