//
//  KeychainManagerProtocol.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

protocol KeychainManagerProtocol {
    func save(key: String, value: String) -> Bool
    func getString(key: String) -> String?
    func save(key: String, value: UUID) -> Bool
}
