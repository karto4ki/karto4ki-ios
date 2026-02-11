//
//  SuccessResponse.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 11.02.2026.
//

import Foundation

struct SuccessResponse<T: Codable>: Codable {
    let data: T
}
