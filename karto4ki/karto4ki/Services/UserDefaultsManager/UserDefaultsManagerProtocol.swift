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
}
