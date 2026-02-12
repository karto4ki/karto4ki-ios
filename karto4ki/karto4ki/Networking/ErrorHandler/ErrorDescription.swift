//
//  ErrorDescription.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 12.02.2026.
//

import Foundation

struct ErrorDescription {
    var message: String?
    var type: ErrorOutput
}

enum ErrorOutput {
    case Alert
    case DisappearingLabel
    case None
}
