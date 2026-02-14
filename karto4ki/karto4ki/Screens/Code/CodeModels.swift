//
//  CodeModels.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 14.02.2026.
//

import Foundation

enum CodeModels {
    
    struct VerifyCodeRequest: Codable {
        let signupKey: String
        let code: String
    }
}
