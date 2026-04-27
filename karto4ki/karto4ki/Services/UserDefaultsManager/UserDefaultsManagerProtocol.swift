//
//  UserDefaultsManagerProtocol.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

protocol UserDefaultsManagerProtocol {
    func putOnboardingCompleted()
    func isOnboardingCompleted() -> Bool
    func saveEmail(_ email: String)
    func saveName(_ name: String)
    func saveUsername(_ username: String)
    func savePrivateProfile(_ profile: PrivateUserProfile)
    func loadPrivateProfile() -> PrivateUserProfile?
    /// Кэш сессии (почта/имя из потока входа), без флага онбординга.
    func clearSessionCaches()
}
