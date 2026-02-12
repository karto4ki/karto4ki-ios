//
//  KeychainManager.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

final class KeychainManager: KeychainManagerProtocol {
    
    enum Keys: String {
        case refreshToken = "refreshToken"
        case accessToken = "accessToken"
        case signinCode = "signinCode"
    }
    
    enum KeychainError: Error {
        case saveError
        case getError
        case deleteError
    }
    
    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    @discardableResult
    func save(key: String, value: UUID) -> Bool {
        return save(key: key, value: value.uuidString)
    }
    
    func getString(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data,
              let valueString = String(data: data, encoding: .utf8) else { return nil }
        return valueString
    }
    
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    func deleteTokens() -> Bool {
        return (delete(key: KeychainManager.Keys.accessToken.rawValue) && delete(key: KeychainManager.Keys.refreshToken.rawValue))
    }
}
